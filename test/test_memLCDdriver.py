import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.i_reset     <= 1
    dut.i_spi_mosi  <= 0
    dut.i_spi_nss   <= 1
    dut.i_spi_clk   <= 0
    await ClockCycles(dut.i_clk, 5)
    dut.i_reset <= 0
    await ClockCycles(dut.i_clk, 5)

async def send_byte(dut, data):
    dut.i_spi_nss   <= 0 # start data packet
    for i in range(8):
        dut.i_spi_clk   <= 0
        dut.i_spi_mosi  <= (data >> (7-i)) & 0x1
        await ClockCycles(dut.i_clk, 4)
        dut.i_spi_clk   <= 1
        await ClockCycles(dut.i_clk, 4)

    dut.i_spi_clk   <= 0
    await ClockCycles(dut.i_clk, 4)
    dut.i_spi_mosi  <= 0
    dut.i_spi_nss   <= 1 # end data packet
    await ClockCycles(dut.i_clk, 8)


async def send_word(dut, data):
    dut.i_spi_nss   <= 0 # start data packet
    for i in range(32):
        dut.i_spi_clk   <= 0
        dut.i_spi_mosi  <= (data >> (31-i)) & 0x1
        await ClockCycles(dut.i_clk, 4)
        dut.i_spi_clk   <= 1
        await ClockCycles(dut.i_clk, 4)

    dut.i_spi_clk   <= 0
    await ClockCycles(dut.i_clk, 4)
    dut.i_spi_mosi  <= 0 
    dut.i_spi_nss   <= 1 # end data packet
    await ClockCycles(dut.i_clk, 8)

@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.i_clk, 10, units="ns") # 100MHz

    cocotb.fork(clock.start())

    await reset(dut)

    # Test sending byte packets when FIFO is not full
    data = 0x01
    packet_count = 0
    send_packet = 0
    while (packet_count < 120*640*1): # send image frames (120*640 for a frame)
        if (dut.o_wfull == 1):
            send_packet = 0
        if (dut.o_rempty_almost == 1):
            send_packet = 1

        if (send_packet == 1):
            packet_count = packet_count + 1
            await send_byte(dut, data)
            data = data + 0x01
            if (data > 0x3F):
                data = 0x01 

        await ClockCycles(dut.i_clk, 1)

    # Flush the FIFO and finish signaling
    while (dut.o_rempty == 0):
        await ClockCycles(dut.i_clk, 10)
    await ClockCycles(dut.i_clk, 500000) # 5ms
