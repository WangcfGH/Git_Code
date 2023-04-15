#pragma once
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

namespace siphash {
uint64_t siphash(const uint8_t* in, const size_t inlen, const uint8_t* k);
uint64_t siphash_nocase(const uint8_t* in, const size_t inlen, const uint8_t* k);
}