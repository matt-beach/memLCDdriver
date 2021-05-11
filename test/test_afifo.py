import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.i_wdata     <= 0
    dut.i_winc      <= 0
    dut.i_rinc      <= 0
    dut.i_wrst_n    <= 0
    dut.i_rrst_n    <= 0

    await ClockCycles(dut.i_wclk, 5)
    dut.i_wrst_n <= 1
    dut.i_rrst_n <= 1
    await ClockCycles(dut.i_wclk, 5)


@cocotb.test()
async def test_all(dut):
    clock_w = Clock(dut.i_wclk, 10, units="us")
    clock_r = Clock(dut.i_rclk, 20, units="us")

    cocotb.fork(clock_w.start())
    cocotb.fork(clock_r.start())    

    await reset(dut)

    dut.i_winc <= 1
    data = 0
    for i in range(20):
        data = data + 1
        dut.i_wdata <= data
        await ClockCycles(dut.i_wclk, 1)
    dut.i_winc <= 0

    await ClockCycles(dut.i_wclk, 5)

    dut.i_rinc <= 1
    for i in range(20):
        await ClockCycles(dut.i_rclk, 1)
    dut.i_rinc <= 0

    await ClockCycles(dut.i_rclk, 5)
