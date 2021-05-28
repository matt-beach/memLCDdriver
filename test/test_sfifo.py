import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.i_wdata     <= 0
    dut.i_winc      <= 0
    dut.i_rinc      <= 0
    dut.i_reset     <= 1

    await ClockCycles(dut.i_clk, 5)
    dut.i_reset     <= 0
    await ClockCycles(dut.i_clk, 5)


@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.i_clk, 10, units="ns")

    cocotb.fork(clock.start())

    await reset(dut)

    dut.i_winc <= 1
    data = 0
    for i in range(20):
        data = data + 1
        dut.i_wdata <= data
        await ClockCycles(dut.i_clk, 1)
    dut.i_winc <= 0

    await ClockCycles(dut.i_clk, 5)

    dut.i_rinc <= 1
    for i in range(20):
        await ClockCycles(dut.i_clk, 1)
    dut.i_rinc <= 0

    assert dut.o_rdata == 15

    await ClockCycles(dut.i_clk, 5)
