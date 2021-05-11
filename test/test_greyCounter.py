import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

clocks_per_phase = 10
max_count = 32

async def reset(dut):
    dut.i_reset  <= 1
    dut.i_enable <= 0
    await ClockCycles(dut.i_clk, 5)
    dut.i_reset <= 0;
    await ClockCycles(dut.i_clk, 5)


@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.i_clk, 10, units="us")

    cocotb.fork(clock.start())

    await reset(dut)

    await ClockCycles(dut.i_clk, 5)

    assert dut.i_enable == 0

    dut.i_enable <= 1 # enable the counter

    for i in range(max_count):
        await ClockCycles(dut.i_clk, 1)