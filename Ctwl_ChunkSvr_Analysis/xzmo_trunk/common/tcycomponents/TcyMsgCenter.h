#pragma once
#include <memory>
#include <functional>

class TcyMsgCenterImp;
struct MsgOperInfo
{
    int msgid;
    std::function<void(LPCONTEXT_HEAD, LPREQUEST)> oper;
};

class TcyMsgCenter
{
public:
    TcyMsgCenter();
    ~TcyMsgCenter();

    void setMsgOper(int msgid, std::function<void(LPCONTEXT_HEAD, LPREQUEST)> oper);
    void setMsgOper(std::vector<MsgOperInfo>& msgopers);

    bool notify(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    void clear();
private:
    std::unique_ptr<TcyMsgCenterImp> m_imp;
};

struct TcyMsgBuffer
{
public:
	template <typename T>
	TcyMsgBuffer& append(T* t) {
		static_assert(std::is_pod<T>::value, "must pod struct");
		m_buffer.append((char*)(t), sizeof(T));
		return *this;
	}

	template <typename T>
	TcyMsgBuffer& append(T* t, int size) {
		m_buffer.append((char*)t, size);
		return *this;
	}

	template <typename T>
	T* cast() {
		return (T*)m_buffer.data();
	}

	void* data() {
		return cast<void>();
	}

	std::size_t size() {
		return m_buffer.size();
	}

	template <typename T>	// T is google::protobuf::Message
	void packPbMessage(T& msg) {
		std::string s;
		try {
			msg.SerializeToString(&s);
		}
		catch (std::exception & e) {
			LOG_TRACE("pb serialize error<%s>", e.what());
			LOG_ERROR("pb serialize error<%s>", e.what());
		}
		m_buffer.append(s);
	}

	void packContextHead(LPREQUEST lpRequest) {
		this->append(lpRequest->pDataPtr, sizeof(CONTEXT_HEAD) * lpRequest->head.nRepeated);
	}
private:
	std::string m_buffer;
};

struct TcyMsgHead
{
    REQUEST         requst;
    CONTEXT_HEAD    context;
    TcyMsgHead(const REQUEST& r, const CONTEXT_HEAD& c): requst(r), context(c) {}
    ~TcyMsgHead();
};

// 把request.pDataPtr拷贝了一份，原来的pRequest内的数据仍可使用
std::shared_ptr<TcyMsgHead>
CopyTcyMsgHead(LPREQUEST pReqeust, LPCONTEXT_HEAD pContext);

// 直接把reqeust.pDataPtr的数据指针转移出去，pRequest.pDataPtr将修改为nullptr
std::shared_ptr<TcyMsgHead>
MoveTcyMsgHead(LPREQUEST pRequest, LPCONTEXT_HEAD pContext);


#define AUTO_REGISTER_MSG_OPERATOR(msg_center, msg_id, msg_opera)   \
    msg_center->setMsgOper(msg_id, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest){this->msg_opera(lpContext, lpRequest);});

template<typename T>
inline T* RequestDataParse(LPREQUEST lpReqesut, bool check = true)
{
    if (check)
    {
        // check size
        if (sizeof(T) > (lpReqesut->nDataLen - lpReqesut->head.nRepeated * sizeof(CONTEXT_HEAD)))
        {
            return nullptr;
        }
    }
    return reinterpret_cast<T*>((PBYTE(lpReqesut->pDataPtr) + lpReqesut->head.nRepeated * sizeof(CONTEXT_HEAD)));
}

inline LPCONTEXT_HEAD RequestDataToContext(LPREQUEST lpReqesut, int index = 0)
{
    if (lpReqesut->head.nRepeated <= index)
    {
        return nullptr;
    }
    if (lpReqesut->nDataLen < (index * sizeof(CONTEXT_HEAD)))
    {
        return nullptr;
    }
    PBYTE begin = (PBYTE)lpReqesut->pDataPtr;
    return (LPCONTEXT_HEAD)(begin + index * sizeof(CONTEXT_HEAD));
}

// 解析一个context 即可
inline PBYTE RequestContextLeftData(LPREQUEST lpReqesut, int& dataSize) {
	if (lpReqesut->head.nRepeated == 0) {
		dataSize = lpReqesut->nDataLen;
		return (PBYTE)lpReqesut->pDataPtr;
	}
	dataSize = lpReqesut->nDataLen - sizeof(CONTEXT_HEAD);
	PBYTE begin = (PBYTE)lpReqesut->pDataPtr;
	return (PBYTE)(begin + sizeof(CONTEXT_HEAD));
}

// 解析所有context 仅剩data
inline PBYTE RequestAllContextLeftData(LPREQUEST lpReqesut, int& dataSize) {
	if (lpReqesut->head.nRepeated == 0) {
		dataSize = lpReqesut->nDataLen;
		return (PBYTE)lpReqesut->pDataPtr;
	}
	dataSize = lpReqesut->nDataLen - sizeof(CONTEXT_HEAD) * lpReqesut->head.nRepeated;
	PBYTE begin = (PBYTE)lpReqesut->pDataPtr;
	return (PBYTE)(begin + sizeof(CONTEXT_HEAD));
}

// 解析Pb数据
template <typename T>
std::unique_ptr<T> RequestToPbMessage(LPREQUEST lpReqesut) {
	int size = 0;
	auto pData = RequestAllContextLeftData(lpReqesut, size);
	std::unique_ptr<T> t = std::make_unique<T>();
	if (!t->ParseFromArray(pData, size)) {
		return nullptr;
	}
	return t;
}
