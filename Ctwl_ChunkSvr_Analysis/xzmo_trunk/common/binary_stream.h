/*
	@描述：可以方便地使用进行进行序列化，使用<< >>操作符进行输入输出操作
	@作者：李威
	@日期：2018.04.03
*/

#ifndef _BINARY_STREAM_H_
#define _BINARY_STREAM_H_

#include <stdint.h>
#include <deque>
#include <vector>
#include <memory>
#include <utility>
#include <type_traits>

class binary_stream {
protected:
	std::deque<int8_t> buff;
	std::unique_ptr<int8_t[]> tmpbuff;
	bool eof;
	bool change;

	bool write(int8_t v) {
		buff.push_back(v);
		return true;
	}

	template<typename T>
	typename std::enable_if<
		std::is_pod<T>::value, 
	bool>::type	write(const T& v) 
	{
		for (size_t i = 0; i < sizeof(v); i++) {
			buff.push_back(((int8_t*)&v)[i]);
		}
		return true;
	}


	bool write(const std::string& s)
	{
		(void)write(s.size() + 1);
		for (size_t i = 0; i < s.size(); i++) {
			(void)write(s[i]);
		}
		(void)write('\0');
		return true;
	}

	template<typename T>
	bool write(const std::vector<T>& v) 
	{
		(void)write(v.size());
		for (size_t i = 0; i < v.size(); i++) {
			(void)write(v[i]);
		}
		return true;
	}

	template<typename T, typename S>
	typename std::enable_if<
		std::is_pod<T>::value && std::is_integral<S>::value,
	bool>::type write(const std::pair<T*, S>& p)
	{
		int8_t* ptr = (int8_t*)(p.first);
		size_t len = p.second;
		for (size_t i = 0; i < len; i++) {
			buff.push_back(ptr[i]);
		}
		return true;
	}

	template<typename T>
	typename std::enable_if<
		std::is_pod<T>::value,
	bool>::type read(T& v) 
	{
		if (buff.size() < sizeof(v)) {
			return false;
		}
		for (size_t i = 0; i < sizeof(v); i++) {
			((int8_t*)&v)[i] = buff.front();
			buff.pop_front();
		}
		return true;
	}

	bool read(std::string& s) 
	{
		size_t sz = 0;
		if (!read(sz)) {
			return false;
		}
		if (sz <= 0) {
			return false;
		}
		s.resize(sz);
		for (size_t i = 0; i < sz; i++) {
			if (!read(s[i])) {
				return false;
			}
		}
		s.resize(sz - 1);
		return true;
	}

	template<typename T>
	bool read(std::vector<T>& v) 
	{
		size_t sz = 0;
		if (!read(sz)) {
			return false;
		}
		v.resize(sz);
		for (size_t i = 0; i < sz; i++) {
			if (!read(v[i])) {
				return false;
			}
		}
		return true;
	}


	template<typename T, typename S>
	typename std::enable_if<
		std::is_pod<T>::value && std::is_integral<S>::value,
	bool>::type read(std::pair<T*, S>& p)
	{
		int8_t* ptr = (int8_t*)(p.first);
		size_t len = p.second;
		for (size_t i = 0; i < len; i++) {
			ptr[i] = buff.front();
			buff.pop_front();
		}
		return true;
	}
public:
	binary_stream() :eof(false), change(false) {}
	~binary_stream() {}

	binary_stream(const binary_stream& bs) :eof(false), change(true) {
		buff = bs.buff;
	}

	binary_stream(void* ptr, size_t len) :eof(false), change(true) {
		for (size_t i = 0; i < len; i++) {
			(void)write(((int8_t*)ptr)[i]);
		}
	}

	operator bool() { return !eof; }

	size_t size() { return buff.size(); }

	int8_t* data() {
		size_t sz = buff.size();

		if (sz == 0) {
			return nullptr;
		}

		if (change) {
			tmpbuff.reset(new int8_t[sz]);
			for (size_t i = 0; i < sz; i++) {
				tmpbuff[i] = buff[i];
			}
			change = false;
		}
		return tmpbuff.get();
	}

	template<typename T>
	binary_stream& operator >>(T& v) {
		eof = !read(v);
		change = true;
		return *this;
	}

	template<typename T>
	binary_stream& operator <<(const T& v) {
		eof = !write(v);
		change = true;
		return *this;
	}

	binary_stream& operator =(const binary_stream& bs) {
		if (&bs != this) {
			buff = bs.buff;
			eof = false;
			change = true;
		}
		return *this;
	}
};


#endif