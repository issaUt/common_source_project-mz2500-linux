/*
	SHARP MZ-2500 Emulator 'EmuZ-2500'

	Author : Takeda.Toshiya
	Date   : 2006.12.01 -

	[ MZ-1R37 (640KB EMM) ]
*/

#include "mz1r37.h"
#include "../fileio.h"

namespace MZ2500 {

void MZ1R37::initialize()
{
	buffer = (uint8_t*)calloc(MZ1R37_EMM_SIZE, sizeof(uint8_t));
	address = 0;
}

void MZ1R37::release()
{
	if(buffer != NULL) {
		free(buffer);
	}
}

void MZ1R37::write_io8(uint32_t addr, uint32_t data)
{
	switch(addr & 0xff) {
	case 0xac:
		address = ((addr & 0xff00) << 8) | (data << 8) | (address & 0x0000ff);
		break;
	case 0xad:
		address = (address & 0xffff00) | (addr >> 8);
		if(address < MZ1R37_EMM_SIZE) {
			buffer[address] = data;
		}
		break;
	}
}

uint32_t MZ1R37::read_io8(uint32_t addr)
{
	switch(addr & 0xff) {
	case 0xad:
		address = (address & 0xffff00) | (addr >> 8);
		if(address < MZ1R37_EMM_SIZE) {
			return buffer[address];
		}
		break;
	}
	return 0xff;
}

#ifdef USE_DEBUGGER
uint64_t MZ1R37::get_debug_data_addr_space()
{
	return MZ1R37_EMM_SIZE;
}

void MZ1R37::write_debug_data8(uint32_t addr, uint32_t data)
{
	if(addr < MZ1R37_EMM_SIZE) {
		buffer[addr] = data;
	}
}

uint32_t MZ1R37::read_debug_data8(uint32_t addr)
{
	if(addr < MZ1R37_EMM_SIZE) {
		return buffer[addr];
	}
	return 0;
}

bool MZ1R37::get_debug_regs_info(_TCHAR *buffer_text, size_t buffer_len)
{
	my_stprintf_s(buffer_text, buffer_len, _T("Address = %04Xxx\n"), (address & 0xffff00) >> 8);
	return true;
}
#endif

#define STATE_VERSION	1

bool MZ1R37::process_state(FILEIO* state_fio, bool loading)
{
	if(!state_fio->StateCheckUint32(STATE_VERSION)) {
		return false;
	}
	if(!state_fio->StateCheckInt32(this_device_id)) {
		return false;
	}
	state_fio->StateArray(buffer, MZ1R37_EMM_SIZE, 1);
	state_fio->StateValue(address);
	return true;
}

}
