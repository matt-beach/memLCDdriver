import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.i_reset     <= 1
    dut.i_rempty    <= 1
    dut.i_data      <= 0
    await ClockCycles(dut.i_clk, 5)
    dut.i_reset     <= 0
    await ClockCycles(dut.i_clk, 5)

@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.i_clk, 0.2, units="us") # 5MHz

    cocotb.fork(clock.start())

    await reset(dut)

    dut.i_rempty <= 0
    data = 0x01
    for i in range(100000):
        if (dut.o_rinc == 1):
            dut.i_data  <= data
            data = data + 0x01
            if (data > 0x3F):
                data = 0x01 
            
        await ClockCycles(dut.i_clk, 1)

    await ClockCycles(dut.i_clk, 5)
