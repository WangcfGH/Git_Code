// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: online.proto

#ifndef PROTOBUF_online_2eproto__INCLUDED
#define PROTOBUF_online_2eproto__INCLUDED

#include <string>

#include <google/protobuf/stubs/common.h>

#if GOOGLE_PROTOBUF_VERSION < 3005000
#error This file was generated by a newer version of protoc which is
#error incompatible with your Protocol Buffer headers.  Please update
#error your headers.
#endif
#if 3005000 < GOOGLE_PROTOBUF_MIN_PROTOC_VERSION
#error This file was generated by an older version of protoc which is
#error incompatible with your Protocol Buffer headers.  Please
#error regenerate this file with a newer version of protoc.
#endif

#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/arena.h>
#include <google/protobuf/arenastring.h>
#include <google/protobuf/generated_message_table_driven.h>
#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/metadata.h>
#include <google/protobuf/message.h>
#include <google/protobuf/repeated_field.h>  // IWYU pragma: export
#include <google/protobuf/extension_set.h>  // IWYU pragma: export
#include <google/protobuf/unknown_field_set.h>
// @@protoc_insertion_point(includes)

namespace protobuf_online_2eproto {
// Internal implementation detail -- do not use these members.
struct TableStruct {
  static const ::google::protobuf::internal::ParseTableField entries[];
  static const ::google::protobuf::internal::AuxillaryParseTableField aux[];
  static const ::google::protobuf::internal::ParseTable schema[2];
  static const ::google::protobuf::internal::FieldMetadata field_metadata[];
  static const ::google::protobuf::internal::SerializationTable serialization_table[];
  static const ::google::protobuf::uint32 offsets[];
};
void AddDescriptors();
void InitDefaultsON_LINE_DATAImpl();
void InitDefaultsON_LINE_DATA();
void InitDefaultsON_LINE_REWARDImpl();
void InitDefaultsON_LINE_REWARD();
inline void InitDefaults() {
  InitDefaultsON_LINE_DATA();
  InitDefaultsON_LINE_REWARD();
}
}  // namespace protobuf_online_2eproto
namespace online {
class ON_LINE_DATA;
class ON_LINE_DATADefaultTypeInternal;
extern ON_LINE_DATADefaultTypeInternal _ON_LINE_DATA_default_instance_;
class ON_LINE_REWARD;
class ON_LINE_REWARDDefaultTypeInternal;
extern ON_LINE_REWARDDefaultTypeInternal _ON_LINE_REWARD_default_instance_;
}  // namespace online
namespace online {

// ===================================================================

class ON_LINE_DATA : public ::google::protobuf::Message /* @@protoc_insertion_point(class_definition:online.ON_LINE_DATA) */ {
 public:
  ON_LINE_DATA();
  virtual ~ON_LINE_DATA();

  ON_LINE_DATA(const ON_LINE_DATA& from);

  inline ON_LINE_DATA& operator=(const ON_LINE_DATA& from) {
    CopyFrom(from);
    return *this;
  }
  #if LANG_CXX11
  ON_LINE_DATA(ON_LINE_DATA&& from) noexcept
    : ON_LINE_DATA() {
    *this = ::std::move(from);
  }

  inline ON_LINE_DATA& operator=(ON_LINE_DATA&& from) noexcept {
    if (GetArenaNoVirtual() == from.GetArenaNoVirtual()) {
      if (this != &from) InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }
  #endif
  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _internal_metadata_.unknown_fields();
  }
  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return _internal_metadata_.mutable_unknown_fields();
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const ON_LINE_DATA& default_instance();

  static void InitAsDefaultInstance();  // FOR INTERNAL USE ONLY
  static inline const ON_LINE_DATA* internal_default_instance() {
    return reinterpret_cast<const ON_LINE_DATA*>(
               &_ON_LINE_DATA_default_instance_);
  }
  static PROTOBUF_CONSTEXPR int const kIndexInFileMessages =
    0;

  void Swap(ON_LINE_DATA* other);
  friend void swap(ON_LINE_DATA& a, ON_LINE_DATA& b) {
    a.Swap(&b);
  }

  // implements Message ----------------------------------------------

  inline ON_LINE_DATA* New() const PROTOBUF_FINAL { return New(NULL); }

  ON_LINE_DATA* New(::google::protobuf::Arena* arena) const PROTOBUF_FINAL;
  void CopyFrom(const ::google::protobuf::Message& from) PROTOBUF_FINAL;
  void MergeFrom(const ::google::protobuf::Message& from) PROTOBUF_FINAL;
  void CopyFrom(const ON_LINE_DATA& from);
  void MergeFrom(const ON_LINE_DATA& from);
  void Clear() PROTOBUF_FINAL;
  bool IsInitialized() const PROTOBUF_FINAL;

  size_t ByteSizeLong() const PROTOBUF_FINAL;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input) PROTOBUF_FINAL;
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const PROTOBUF_FINAL;
  ::google::protobuf::uint8* InternalSerializeWithCachedSizesToArray(
      bool deterministic, ::google::protobuf::uint8* target) const PROTOBUF_FINAL;
  int GetCachedSize() const PROTOBUF_FINAL { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const PROTOBUF_FINAL;
  void InternalSwap(ON_LINE_DATA* other);
  private:
  inline ::google::protobuf::Arena* GetArenaNoVirtual() const {
    return NULL;
  }
  inline void* MaybeArenaPtr() const {
    return NULL;
  }
  public:

  ::google::protobuf::Metadata GetMetadata() const PROTOBUF_FINAL;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // optional string config = 6;
  bool has_config() const;
  void clear_config();
  static const int kConfigFieldNumber = 6;
  const ::std::string& config() const;
  void set_config(const ::std::string& value);
  #if LANG_CXX11
  void set_config(::std::string&& value);
  #endif
  void set_config(const char* value);
  void set_config(const char* value, size_t size);
  ::std::string* mutable_config();
  ::std::string* release_config();
  void set_allocated_config(::std::string* config);

  // required int32 user_id = 1;
  bool has_user_id() const;
  void clear_user_id();
  static const int kUserIdFieldNumber = 1;
  ::google::protobuf::int32 user_id() const;
  void set_user_id(::google::protobuf::int32 value);

  // optional int32 online_time = 2;
  bool has_online_time() const;
  void clear_online_time();
  static const int kOnlineTimeFieldNumber = 2;
  ::google::protobuf::int32 online_time() const;
  void set_online_time(::google::protobuf::int32 value);

  // optional int32 condition = 3;
  bool has_condition() const;
  void clear_condition();
  static const int kConditionFieldNumber = 3;
  ::google::protobuf::int32 condition() const;
  void set_condition(::google::protobuf::int32 value);

  // optional int32 reward = 4;
  bool has_reward() const;
  void clear_reward();
  static const int kRewardFieldNumber = 4;
  ::google::protobuf::int32 reward() const;
  void set_reward(::google::protobuf::int32 value);

  // optional int32 already_reward = 5;
  bool has_already_reward() const;
  void clear_already_reward();
  static const int kAlreadyRewardFieldNumber = 5;
  ::google::protobuf::int32 already_reward() const;
  void set_already_reward(::google::protobuf::int32 value);

  // @@protoc_insertion_point(class_scope:online.ON_LINE_DATA)
 private:
  void set_has_user_id();
  void clear_has_user_id();
  void set_has_online_time();
  void clear_has_online_time();
  void set_has_condition();
  void clear_has_condition();
  void set_has_reward();
  void clear_has_reward();
  void set_has_already_reward();
  void clear_has_already_reward();
  void set_has_config();
  void clear_has_config();

  ::google::protobuf::internal::InternalMetadataWithArena _internal_metadata_;
  ::google::protobuf::internal::HasBits<1> _has_bits_;
  mutable int _cached_size_;
  ::google::protobuf::internal::ArenaStringPtr config_;
  ::google::protobuf::int32 user_id_;
  ::google::protobuf::int32 online_time_;
  ::google::protobuf::int32 condition_;
  ::google::protobuf::int32 reward_;
  ::google::protobuf::int32 already_reward_;
  friend struct ::protobuf_online_2eproto::TableStruct;
  friend void ::protobuf_online_2eproto::InitDefaultsON_LINE_DATAImpl();
};
// -------------------------------------------------------------------

class ON_LINE_REWARD : public ::google::protobuf::Message /* @@protoc_insertion_point(class_definition:online.ON_LINE_REWARD) */ {
 public:
  ON_LINE_REWARD();
  virtual ~ON_LINE_REWARD();

  ON_LINE_REWARD(const ON_LINE_REWARD& from);

  inline ON_LINE_REWARD& operator=(const ON_LINE_REWARD& from) {
    CopyFrom(from);
    return *this;
  }
  #if LANG_CXX11
  ON_LINE_REWARD(ON_LINE_REWARD&& from) noexcept
    : ON_LINE_REWARD() {
    *this = ::std::move(from);
  }

  inline ON_LINE_REWARD& operator=(ON_LINE_REWARD&& from) noexcept {
    if (GetArenaNoVirtual() == from.GetArenaNoVirtual()) {
      if (this != &from) InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }
  #endif
  inline const ::google::protobuf::UnknownFieldSet& unknown_fields() const {
    return _internal_metadata_.unknown_fields();
  }
  inline ::google::protobuf::UnknownFieldSet* mutable_unknown_fields() {
    return _internal_metadata_.mutable_unknown_fields();
  }

  static const ::google::protobuf::Descriptor* descriptor();
  static const ON_LINE_REWARD& default_instance();

  static void InitAsDefaultInstance();  // FOR INTERNAL USE ONLY
  static inline const ON_LINE_REWARD* internal_default_instance() {
    return reinterpret_cast<const ON_LINE_REWARD*>(
               &_ON_LINE_REWARD_default_instance_);
  }
  static PROTOBUF_CONSTEXPR int const kIndexInFileMessages =
    1;

  void Swap(ON_LINE_REWARD* other);
  friend void swap(ON_LINE_REWARD& a, ON_LINE_REWARD& b) {
    a.Swap(&b);
  }

  // implements Message ----------------------------------------------

  inline ON_LINE_REWARD* New() const PROTOBUF_FINAL { return New(NULL); }

  ON_LINE_REWARD* New(::google::protobuf::Arena* arena) const PROTOBUF_FINAL;
  void CopyFrom(const ::google::protobuf::Message& from) PROTOBUF_FINAL;
  void MergeFrom(const ::google::protobuf::Message& from) PROTOBUF_FINAL;
  void CopyFrom(const ON_LINE_REWARD& from);
  void MergeFrom(const ON_LINE_REWARD& from);
  void Clear() PROTOBUF_FINAL;
  bool IsInitialized() const PROTOBUF_FINAL;

  size_t ByteSizeLong() const PROTOBUF_FINAL;
  bool MergePartialFromCodedStream(
      ::google::protobuf::io::CodedInputStream* input) PROTOBUF_FINAL;
  void SerializeWithCachedSizes(
      ::google::protobuf::io::CodedOutputStream* output) const PROTOBUF_FINAL;
  ::google::protobuf::uint8* InternalSerializeWithCachedSizesToArray(
      bool deterministic, ::google::protobuf::uint8* target) const PROTOBUF_FINAL;
  int GetCachedSize() const PROTOBUF_FINAL { return _cached_size_; }
  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const PROTOBUF_FINAL;
  void InternalSwap(ON_LINE_REWARD* other);
  private:
  inline ::google::protobuf::Arena* GetArenaNoVirtual() const {
    return NULL;
  }
  inline void* MaybeArenaPtr() const {
    return NULL;
  }
  public:

  ::google::protobuf::Metadata GetMetadata() const PROTOBUF_FINAL;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  // optional .online.ON_LINE_DATA user_data = 5;
  bool has_user_data() const;
  void clear_user_data();
  static const int kUserDataFieldNumber = 5;
  const ::online::ON_LINE_DATA& user_data() const;
  ::online::ON_LINE_DATA* release_user_data();
  ::online::ON_LINE_DATA* mutable_user_data();
  void set_allocated_user_data(::online::ON_LINE_DATA* user_data);

  // required int32 user_id = 1;
  bool has_user_id() const;
  void clear_user_id();
  static const int kUserIdFieldNumber = 1;
  ::google::protobuf::int32 user_id() const;
  void set_user_id(::google::protobuf::int32 value);

  // optional int32 shared = 2;
  bool has_shared() const;
  void clear_shared();
  static const int kSharedFieldNumber = 2;
  ::google::protobuf::int32 shared() const;
  void set_shared(::google::protobuf::int32 value);

  // optional int32 result = 3;
  bool has_result() const;
  void clear_result();
  static const int kResultFieldNumber = 3;
  ::google::protobuf::int32 result() const;
  void set_result(::google::protobuf::int32 value);

  // optional int32 reward = 4;
  bool has_reward() const;
  void clear_reward();
  static const int kRewardFieldNumber = 4;
  ::google::protobuf::int32 reward() const;
  void set_reward(::google::protobuf::int32 value);

  // @@protoc_insertion_point(class_scope:online.ON_LINE_REWARD)
 private:
  void set_has_user_id();
  void clear_has_user_id();
  void set_has_shared();
  void clear_has_shared();
  void set_has_result();
  void clear_has_result();
  void set_has_reward();
  void clear_has_reward();
  void set_has_user_data();
  void clear_has_user_data();

  ::google::protobuf::internal::InternalMetadataWithArena _internal_metadata_;
  ::google::protobuf::internal::HasBits<1> _has_bits_;
  mutable int _cached_size_;
  ::online::ON_LINE_DATA* user_data_;
  ::google::protobuf::int32 user_id_;
  ::google::protobuf::int32 shared_;
  ::google::protobuf::int32 result_;
  ::google::protobuf::int32 reward_;
  friend struct ::protobuf_online_2eproto::TableStruct;
  friend void ::protobuf_online_2eproto::InitDefaultsON_LINE_REWARDImpl();
};
// ===================================================================


// ===================================================================

#ifdef __GNUC__
  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif  // __GNUC__
// ON_LINE_DATA

// required int32 user_id = 1;
inline bool ON_LINE_DATA::has_user_id() const {
  return (_has_bits_[0] & 0x00000002u) != 0;
}
inline void ON_LINE_DATA::set_has_user_id() {
  _has_bits_[0] |= 0x00000002u;
}
inline void ON_LINE_DATA::clear_has_user_id() {
  _has_bits_[0] &= ~0x00000002u;
}
inline void ON_LINE_DATA::clear_user_id() {
  user_id_ = 0;
  clear_has_user_id();
}
inline ::google::protobuf::int32 ON_LINE_DATA::user_id() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_DATA.user_id)
  return user_id_;
}
inline void ON_LINE_DATA::set_user_id(::google::protobuf::int32 value) {
  set_has_user_id();
  user_id_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_DATA.user_id)
}

// optional int32 online_time = 2;
inline bool ON_LINE_DATA::has_online_time() const {
  return (_has_bits_[0] & 0x00000004u) != 0;
}
inline void ON_LINE_DATA::set_has_online_time() {
  _has_bits_[0] |= 0x00000004u;
}
inline void ON_LINE_DATA::clear_has_online_time() {
  _has_bits_[0] &= ~0x00000004u;
}
inline void ON_LINE_DATA::clear_online_time() {
  online_time_ = 0;
  clear_has_online_time();
}
inline ::google::protobuf::int32 ON_LINE_DATA::online_time() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_DATA.online_time)
  return online_time_;
}
inline void ON_LINE_DATA::set_online_time(::google::protobuf::int32 value) {
  set_has_online_time();
  online_time_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_DATA.online_time)
}

// optional int32 condition = 3;
inline bool ON_LINE_DATA::has_condition() const {
  return (_has_bits_[0] & 0x00000008u) != 0;
}
inline void ON_LINE_DATA::set_has_condition() {
  _has_bits_[0] |= 0x00000008u;
}
inline void ON_LINE_DATA::clear_has_condition() {
  _has_bits_[0] &= ~0x00000008u;
}
inline void ON_LINE_DATA::clear_condition() {
  condition_ = 0;
  clear_has_condition();
}
inline ::google::protobuf::int32 ON_LINE_DATA::condition() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_DATA.condition)
  return condition_;
}
inline void ON_LINE_DATA::set_condition(::google::protobuf::int32 value) {
  set_has_condition();
  condition_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_DATA.condition)
}

// optional int32 reward = 4;
inline bool ON_LINE_DATA::has_reward() const {
  return (_has_bits_[0] & 0x00000010u) != 0;
}
inline void ON_LINE_DATA::set_has_reward() {
  _has_bits_[0] |= 0x00000010u;
}
inline void ON_LINE_DATA::clear_has_reward() {
  _has_bits_[0] &= ~0x00000010u;
}
inline void ON_LINE_DATA::clear_reward() {
  reward_ = 0;
  clear_has_reward();
}
inline ::google::protobuf::int32 ON_LINE_DATA::reward() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_DATA.reward)
  return reward_;
}
inline void ON_LINE_DATA::set_reward(::google::protobuf::int32 value) {
  set_has_reward();
  reward_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_DATA.reward)
}

// optional int32 already_reward = 5;
inline bool ON_LINE_DATA::has_already_reward() const {
  return (_has_bits_[0] & 0x00000020u) != 0;
}
inline void ON_LINE_DATA::set_has_already_reward() {
  _has_bits_[0] |= 0x00000020u;
}
inline void ON_LINE_DATA::clear_has_already_reward() {
  _has_bits_[0] &= ~0x00000020u;
}
inline void ON_LINE_DATA::clear_already_reward() {
  already_reward_ = 0;
  clear_has_already_reward();
}
inline ::google::protobuf::int32 ON_LINE_DATA::already_reward() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_DATA.already_reward)
  return already_reward_;
}
inline void ON_LINE_DATA::set_already_reward(::google::protobuf::int32 value) {
  set_has_already_reward();
  already_reward_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_DATA.already_reward)
}

// optional string config = 6;
inline bool ON_LINE_DATA::has_config() const {
  return (_has_bits_[0] & 0x00000001u) != 0;
}
inline void ON_LINE_DATA::set_has_config() {
  _has_bits_[0] |= 0x00000001u;
}
inline void ON_LINE_DATA::clear_has_config() {
  _has_bits_[0] &= ~0x00000001u;
}
inline void ON_LINE_DATA::clear_config() {
  config_.ClearToEmptyNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited());
  clear_has_config();
}
inline const ::std::string& ON_LINE_DATA::config() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_DATA.config)
  return config_.GetNoArena();
}
inline void ON_LINE_DATA::set_config(const ::std::string& value) {
  set_has_config();
  config_.SetNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited(), value);
  // @@protoc_insertion_point(field_set:online.ON_LINE_DATA.config)
}
#if LANG_CXX11
inline void ON_LINE_DATA::set_config(::std::string&& value) {
  set_has_config();
  config_.SetNoArena(
    &::google::protobuf::internal::GetEmptyStringAlreadyInited(), ::std::move(value));
  // @@protoc_insertion_point(field_set_rvalue:online.ON_LINE_DATA.config)
}
#endif
inline void ON_LINE_DATA::set_config(const char* value) {
  GOOGLE_DCHECK(value != NULL);
  set_has_config();
  config_.SetNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited(), ::std::string(value));
  // @@protoc_insertion_point(field_set_char:online.ON_LINE_DATA.config)
}
inline void ON_LINE_DATA::set_config(const char* value, size_t size) {
  set_has_config();
  config_.SetNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited(),
      ::std::string(reinterpret_cast<const char*>(value), size));
  // @@protoc_insertion_point(field_set_pointer:online.ON_LINE_DATA.config)
}
inline ::std::string* ON_LINE_DATA::mutable_config() {
  set_has_config();
  // @@protoc_insertion_point(field_mutable:online.ON_LINE_DATA.config)
  return config_.MutableNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited());
}
inline ::std::string* ON_LINE_DATA::release_config() {
  // @@protoc_insertion_point(field_release:online.ON_LINE_DATA.config)
  clear_has_config();
  return config_.ReleaseNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited());
}
inline void ON_LINE_DATA::set_allocated_config(::std::string* config) {
  if (config != NULL) {
    set_has_config();
  } else {
    clear_has_config();
  }
  config_.SetAllocatedNoArena(&::google::protobuf::internal::GetEmptyStringAlreadyInited(), config);
  // @@protoc_insertion_point(field_set_allocated:online.ON_LINE_DATA.config)
}

// -------------------------------------------------------------------

// ON_LINE_REWARD

// required int32 user_id = 1;
inline bool ON_LINE_REWARD::has_user_id() const {
  return (_has_bits_[0] & 0x00000002u) != 0;
}
inline void ON_LINE_REWARD::set_has_user_id() {
  _has_bits_[0] |= 0x00000002u;
}
inline void ON_LINE_REWARD::clear_has_user_id() {
  _has_bits_[0] &= ~0x00000002u;
}
inline void ON_LINE_REWARD::clear_user_id() {
  user_id_ = 0;
  clear_has_user_id();
}
inline ::google::protobuf::int32 ON_LINE_REWARD::user_id() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_REWARD.user_id)
  return user_id_;
}
inline void ON_LINE_REWARD::set_user_id(::google::protobuf::int32 value) {
  set_has_user_id();
  user_id_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_REWARD.user_id)
}

// optional int32 shared = 2;
inline bool ON_LINE_REWARD::has_shared() const {
  return (_has_bits_[0] & 0x00000004u) != 0;
}
inline void ON_LINE_REWARD::set_has_shared() {
  _has_bits_[0] |= 0x00000004u;
}
inline void ON_LINE_REWARD::clear_has_shared() {
  _has_bits_[0] &= ~0x00000004u;
}
inline void ON_LINE_REWARD::clear_shared() {
  shared_ = 0;
  clear_has_shared();
}
inline ::google::protobuf::int32 ON_LINE_REWARD::shared() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_REWARD.shared)
  return shared_;
}
inline void ON_LINE_REWARD::set_shared(::google::protobuf::int32 value) {
  set_has_shared();
  shared_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_REWARD.shared)
}

// optional int32 result = 3;
inline bool ON_LINE_REWARD::has_result() const {
  return (_has_bits_[0] & 0x00000008u) != 0;
}
inline void ON_LINE_REWARD::set_has_result() {
  _has_bits_[0] |= 0x00000008u;
}
inline void ON_LINE_REWARD::clear_has_result() {
  _has_bits_[0] &= ~0x00000008u;
}
inline void ON_LINE_REWARD::clear_result() {
  result_ = 0;
  clear_has_result();
}
inline ::google::protobuf::int32 ON_LINE_REWARD::result() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_REWARD.result)
  return result_;
}
inline void ON_LINE_REWARD::set_result(::google::protobuf::int32 value) {
  set_has_result();
  result_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_REWARD.result)
}

// optional int32 reward = 4;
inline bool ON_LINE_REWARD::has_reward() const {
  return (_has_bits_[0] & 0x00000010u) != 0;
}
inline void ON_LINE_REWARD::set_has_reward() {
  _has_bits_[0] |= 0x00000010u;
}
inline void ON_LINE_REWARD::clear_has_reward() {
  _has_bits_[0] &= ~0x00000010u;
}
inline void ON_LINE_REWARD::clear_reward() {
  reward_ = 0;
  clear_has_reward();
}
inline ::google::protobuf::int32 ON_LINE_REWARD::reward() const {
  // @@protoc_insertion_point(field_get:online.ON_LINE_REWARD.reward)
  return reward_;
}
inline void ON_LINE_REWARD::set_reward(::google::protobuf::int32 value) {
  set_has_reward();
  reward_ = value;
  // @@protoc_insertion_point(field_set:online.ON_LINE_REWARD.reward)
}

// optional .online.ON_LINE_DATA user_data = 5;
inline bool ON_LINE_REWARD::has_user_data() const {
  return (_has_bits_[0] & 0x00000001u) != 0;
}
inline void ON_LINE_REWARD::set_has_user_data() {
  _has_bits_[0] |= 0x00000001u;
}
inline void ON_LINE_REWARD::clear_has_user_data() {
  _has_bits_[0] &= ~0x00000001u;
}
inline void ON_LINE_REWARD::clear_user_data() {
  if (user_data_ != NULL) user_data_->Clear();
  clear_has_user_data();
}
inline const ::online::ON_LINE_DATA& ON_LINE_REWARD::user_data() const {
  const ::online::ON_LINE_DATA* p = user_data_;
  // @@protoc_insertion_point(field_get:online.ON_LINE_REWARD.user_data)
  return p != NULL ? *p : *reinterpret_cast<const ::online::ON_LINE_DATA*>(
      &::online::_ON_LINE_DATA_default_instance_);
}
inline ::online::ON_LINE_DATA* ON_LINE_REWARD::release_user_data() {
  // @@protoc_insertion_point(field_release:online.ON_LINE_REWARD.user_data)
  clear_has_user_data();
  ::online::ON_LINE_DATA* temp = user_data_;
  user_data_ = NULL;
  return temp;
}
inline ::online::ON_LINE_DATA* ON_LINE_REWARD::mutable_user_data() {
  set_has_user_data();
  if (user_data_ == NULL) {
    user_data_ = new ::online::ON_LINE_DATA;
  }
  // @@protoc_insertion_point(field_mutable:online.ON_LINE_REWARD.user_data)
  return user_data_;
}
inline void ON_LINE_REWARD::set_allocated_user_data(::online::ON_LINE_DATA* user_data) {
  ::google::protobuf::Arena* message_arena = GetArenaNoVirtual();
  if (message_arena == NULL) {
    delete user_data_;
  }
  if (user_data) {
    ::google::protobuf::Arena* submessage_arena = NULL;
    if (message_arena != submessage_arena) {
      user_data = ::google::protobuf::internal::GetOwnedMessage(
          message_arena, user_data, submessage_arena);
    }
    set_has_user_data();
  } else {
    clear_has_user_data();
  }
  user_data_ = user_data;
  // @@protoc_insertion_point(field_set_allocated:online.ON_LINE_REWARD.user_data)
}

#ifdef __GNUC__
  #pragma GCC diagnostic pop
#endif  // __GNUC__
// -------------------------------------------------------------------


// @@protoc_insertion_point(namespace_scope)

}  // namespace online

// @@protoc_insertion_point(global_scope)

#endif  // PROTOBUF_online_2eproto__INCLUDED