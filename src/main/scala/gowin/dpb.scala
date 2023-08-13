package gowin

import chisel3._
import chisel3.experimental._

import memory._
import chisel3.util.log2Ceil

case class ReadMode private (val value: String)

object ReadMode {
  val Bypass = ReadMode("1'b0")
  val Pipeline = ReadMode("1'b1")
}

case class WriteMode private (val value: String)

object WriteMode {
  val Normal = WriteMode("2'b00")
  val WriteThrough = WriteMode("2'b01")
}

case class ResetMode private (val value: String)

object ResetMode {
  val Sync = ResetMode("SYNC")
  val Async = ResetMode("ASYNC")
}

/**
  * GOWIN DPB primitive parameters
  * See UG285E for more details
  * @param readMode0  READ_MODE0
  * @param writeMode0 WRITE_MODE0
  * @param bitWidth0  BIT_WIDTH_0
  * @param readMode1  READ_MODE1
  * @param writeMode1 WRITE_MODE1
  * @param bitWidth1  BIT_WIDTH_1
  * @param resetMode  RESET_MODE
  * @param initData   INIT_DATA_00 ~ INIT_DATA_3F
  */
class DPBParams(
    val readMode0: ReadMode = ReadMode.Bypass,
    val writeMode0: WriteMode = WriteMode.Normal,
    val bitWidth0: Int = 16,
    
    val readMode1: ReadMode = ReadMode.Bypass,
    val writeMode1: WriteMode = WriteMode.Normal,
    val bitWidth1: Int = 16,

    val resetMode: ResetMode = ResetMode.Sync,

    // init data
    val initData: Option[Seq[BigInt]] = None,
) {
    def toParamMap(): Map[String, Param] = {
        // Validate params
        val validBitWidth = Seq(1, 2, 4, 8, 16)
        if( !validBitWidth.contains(bitWidth0) ) {
            throw new Exception("Bit width must be one of 1, 2, 4, 8, 16")
        }
        if( !validBitWidth.contains(bitWidth1) ) {
            throw new Exception("Bit width must be one of 1, 2, 4, 8, 16")
        }

        val map = scala.collection.mutable.Map(
            "READ_MODE0" -> RawParam(readMode0.value),
            "READ_MODE1" -> RawParam(readMode1.value),
            "WRITE_MODE0" -> RawParam(writeMode0.value),
            "WRITE_MODE1" -> RawParam(writeMode1.value),
            "BIT_WIDTH_0" -> fromIntToIntParam(bitWidth0),
            "BIT_WIDTH_1" -> fromIntToIntParam(bitWidth1),
            "RESET_MODE" -> fromStringToStringParam(resetMode.value),
            "BLK_SEL_0" -> RawParam("3'b000"),
            "BLK_SEL_1" -> RawParam("3'b000"),
        )
        
        // Construct INIT_DATA params
        this.initData match {
            case Some(data) => {
                if( data.length > 64 ) {
                    throw new Exception("Init data length must be less than 64")
                }
                for( value <- data.zipWithIndex ) {
                    val k = f"INIT_RAM_${value._2}%02X"
                    val v = RawParam(f"256'h${value._1}%032x")
                    map(k) = v
                }
            }
            case None => map
        }

        map.toMap
    }
}

/**
  * GOWIN DPB (Dual Port Block) Primitive
  * See UG285E for more details
  */
class DPB(val dpbParams: DPBParams) extends BlackBox(dpbParams.toParamMap()) {
  val io = IO(new Bundle {
    val DOA = Output(UInt(16.W))
    val DOB = Output(UInt(16.W))
    val DIA = Input(UInt(16.W))
    val DIB = Input(UInt(16.W))
    val ADA = Input(UInt(14.W))
    val ADB = Input(UInt(14.W))
    val WREA = Input(Bool())
    val WREB = Input(Bool())
    val CEA = Input(Bool())
    val CEB = Input(Bool())
    val CLKA = Input(Clock())
    val CLKB = Input(Clock())
    val RESETA = Input(Reset())
    val RESETB = Input(Reset())
    val OCEA = Input(Bool())
    val OCEB = Input(Bool())
    val BLKSELA = Input(UInt(3.W))
    val BLKSELB = Input(UInt(3.W))
  })
}

/**
  * GOWIN Dual Port Memory Wrapper
  * @param portAWidth bit width of port A, valid values are: 1, 2, 4, 8, 16
  * @param portBWidth bit width of port B, valid values are: 1, 2, 4, 8, 16
  * @param numberOfBits total number of bits in the memory. Max number of bits is 16384
  * @param initData initial data to be loaded into the memory. If None, the memory will be initialized to 0, otherwise the length of the sequence must be less than 256 and number of bits of each element must be less than or equal to 256 bits.
  */
class GowinDualPortMemory(val portAWidth: Int, val portBWidth: Int, val numberOfBits: Int, val initData: Option[Seq[BigInt]]) extends Module {
    val io = IO(new Bundle {
        val portA = Flipped(FixedLatencyMemoryPort(portAWidth, numberOfBits))
        val portB = Flipped(FixedLatencyMemoryPort(portBWidth, numberOfBits))
    })

    if( numberOfBits > 16384 ) {
        throw new Exception("numberOfBits must be less than 16384")
    }

    val dpbParams = new DPBParams(
        readMode0 = ReadMode.Bypass,
        writeMode0 = WriteMode.Normal,
        bitWidth0 = portAWidth,
        readMode1 = ReadMode.Bypass,
        writeMode1 = WriteMode.Normal,
        bitWidth1 = portBWidth,
        resetMode = ResetMode.Sync,
        initData = initData,
    )

    val dpb = Module(new DPB(dpbParams))

    withClockAndReset(io.portA.clock, io.portA.reset) {
        dpb.io.CLKA := io.portA.clock
        dpb.io.RESETA := io.portA.reset
        dpb.io.DIA := io.portA.dataIn
        io.portA.dataOut := dpb.io.DOA
        dpb.io.ADA := io.portA.address << log2Ceil(portAWidth)
        dpb.io.CEA := io.portA.chipEnable
        dpb.io.WREA := io.portA.writeEnable
        dpb.io.OCEA := true.B
        dpb.io.BLKSELA := 0.U
    }
    withClockAndReset(io.portB.clock, io.portB.reset) {
        dpb.io.CLKB := io.portB.clock
        dpb.io.RESETB := io.portB.reset
        dpb.io.DIB := io.portB.dataIn
        io.portB.dataOut := dpb.io.DOB
        dpb.io.ADB := io.portB.address << log2Ceil(portBWidth)
        dpb.io.CEB := io.portB.chipEnable
        dpb.io.WREB := io.portB.writeEnable
        dpb.io.OCEB := true.B
        dpb.io.BLKSELB := 0.U
    }
}