// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2021.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)

package video

import chisel3._
import chisel3.util._
import chisel3.experimental.chiselName

@chiselName
class TestPatternGenerator(pixelBits: Int, width: Int, height: Int, val rectSize: Int = 32) extends Module {
    val io = IO(new Bundle{
        val data = Irrevocable(new VideoSignal(pixelBits))
    })

    val valid = RegInit(false.B)
    val pixelData = RegInit(0.U(pixelBits.W))
    val pixelDataValue = WireDefault(0.U(pixelBits.W))
    val startOfFrame = RegInit(false.B)
    val endOfLine = RegInit(false.B)
    val counterH = RegInit(0.U(log2Ceil(width).W))
    val counterV = RegInit(0.U(log2Ceil(height).W))
    
    val rectL = RegInit(0.U(log2Ceil(width).W))
    val rectT = RegInit(0.U(log2Ceil(height).W))
    val rectR = RegInit(rectSize.U(log2Ceil(width).W))
    val rectB = RegInit(rectSize.U(log2Ceil(height).W))
    val directionX = RegInit(false.B)
    val directionY = RegInit(false.B)

    io.data.valid := valid
    io.data.bits.pixelData := pixelData
    io.data.bits.startOfFrame := startOfFrame
    io.data.bits.endOfLine := endOfLine

    valid := true.B

    when( !valid || io.data.ready ) {
        startOfFrame := counterH === 0.U && counterV === 0.U
        endOfLine := counterH === (width - 1).U 

        when( counterH < (width - 1).U ) {
            counterH := counterH + 1.U
        } .otherwise {
            counterH := 0.U 
            when( counterV < (height - 1).U ) {
                counterV := counterV + 1.U
            } .otherwise {
                counterV := 0.U

                // Update rectangle pos
                when(!directionX) {
                    when( rectR < width.U ) {
                        rectL := rectL + 1.U
                        rectR := rectR + 1.U
                    } .otherwise {
                        directionX := true.B
                    }
                } .otherwise {
                    when( rectL > 0.U ) {
                        rectL := rectL - 1.U
                        rectR := rectR - 1.U
                    } .otherwise {
                        directionX := false.B
                    }
                }
                when(!directionY) {
                    when( rectB < height.U ) {
                        rectT := rectT + 1.U
                        rectB := rectB + 1.U
                    } .otherwise {
                        directionY := true.B
                    }
                } .otherwise {
                    when( rectT > 0.U ) {
                        rectT := rectT - 1.U
                        rectB := rectB - 1.U
                    } .otherwise {
                        directionY := false.B
                    }
                }
            }
        }

        def toPixelValue(value: UInt): UInt = {
            if( pixelBits == 24 ) {         // 24bpp BGR888
                value
            } else if( pixelBits == 16 ) {  // 1bpp BGR565
                Cat(value(23, 16+3), value(15, 8+2), value(7, 0+3))
            } else {                        // 8bpp BGR233
                Cat(value(23, 16+6), value(15, 8+5), value(7, 0+5))
            }
        }

        when( rectL <= counterH && counterH < rectR && rectT <= counterV && counterV < rectB ) {
            pixelDataValue := 0.U
        } .elsewhen( counterH < (width * 1 / 7).U ) {
            pixelDataValue := toPixelValue("xffffff".U)
        } .elsewhen( counterH < (width * 2 / 7).U ) {
            pixelDataValue := toPixelValue("xff0000".U)
        } .elsewhen( counterH < (width * 3 / 7).U ) {
            pixelDataValue := toPixelValue("xffff00".U)
        } .elsewhen( counterH < (width * 4 / 7).U ) {
            pixelDataValue := toPixelValue("x00ff00".U)
        } .elsewhen( counterH < (width * 5 / 7).U ) {
            pixelDataValue := toPixelValue("x00ffff".U)
        } .elsewhen( counterH < (width * 6 / 7).U ) {
            pixelDataValue := toPixelValue("x0000ff".U)
        } .otherwise {
            pixelDataValue := toPixelValue("xff00ff".U)
        }
        
        pixelData := Mux(counterV(1, 0) === 0.U || counterH(1, 0) === 0.U, pixelDataValue, toPixelValue("x000000".U))

    }
}