import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.i_reset     <= 1
    dut.i_spi_mosi  <= 0
    dut.i_spi_cs_n   <= 1
    dut.i_spi_clk   <= 0
    await ClockCycles(dut.i_clk, 5)
    dut.i_reset <= 0;
    await ClockCycles(dut.i_clk, 5)

async def send_byte(dut, data):
    dut.i_spi_cs_n   <= 0 # start data packet
    for i in range(8):
        dut.i_spi_clk   <= 0
        dut.i_spi_mosi  <= (data >> (7-i)) & 0x1
        await ClockCycles(dut.i_clk, 5)
        dut.i_spi_clk   <= 1
        await ClockCycles(dut.i_clk, 5)

    dut.i_spi_clk   <= 0
    await ClockCycles(dut.i_clk, 5)
    dut.i_spi_cs_n   <= 1 # end data packet
    await ClockCycles(dut.i_clk, 5)

@cocotb.test()
async def test_all(dut):

    clock = Clock(dut.i_clk, 10, units="us")

    cocotb.fork(clock.start())

    await reset(dut)

    await ClockCycles(dut.i_clk, 10)

    data = 0xAA
    await send_byte(dut, data)
    assert dut.o_rx_data == data

    data = 0xBB
    await send_byte(dut, data)
    assert dut.o_rx_data == data

    for j in range(4):
        data = random.randint(0x00,0xFF)
        await send_byte(dut, data)
        assert dut.o_rx_data == data

    await ClockCycles(dut.i_clk, 10)
