stb_vorbis_close PROTO C :BPPtr
stb_vorbis_decode_filename PROTO C :BPPtr, :BPPtr, :BPPtr, :BPPtr
stb_vorbis_decode_frame_pushdata PROTO C :BPPtr, :BPPtr, :SDWORD, :BPPtr, :BPPtr, :BPPtr
stb_vorbis_decode_memory PROTO C :BPPtr, :SDWORD, :BPPtr, :BPPtr, :BPPtr
stb_vorbis_flush_pushdata PROTO C :BPPtr
stb_vorbis_get_comment PROTO C :BPPtr
stb_vorbis_get_error PROTO C :BPPtr
stb_vorbis_get_file_offset PROTO C :BPPtr
stb_vorbis_get_frame_float PROTO C :BPPtr, :BPPtr, :BPPtr
stb_vorbis_get_frame_short PROTO C :BPPtr, :SDWORD, :BPPtr, :SDWORD
stb_vorbis_get_frame_short_interleaved PROTO C :BPPtr, :SDWORD, :BPPtr, :SDWORD
stb_vorbis_get_info PROTO C :BPPtr
stb_vorbis_get_sample_offset PROTO C :BPPtr
stb_vorbis_get_samples_float PROTO C :BPPtr, :SDWORD, :BPPtr, :SDWORD
stb_vorbis_get_samples_float_interleaved PROTO C :BPPtr, :SDWORD, :BPPtr, :SDWORD
stb_vorbis_get_samples_short PROTO C :BPPtr, :SDWORD, :BPPtr, :SDWORD
stb_vorbis_get_samples_short_interleaved PROTO C :BPPtr, :SDWORD, :BPPtr, :SDWORD
stb_vorbis_open_file PROTO C :BPPtr, :SDWORD, :BPPtr, :BPPtr
stb_vorbis_open_file_section PROTO C :BPPtr, :SDWORD, :BPPtr, :BPPtr, :DWORD
stb_vorbis_open_filename PROTO C :BPPtr, :BPPtr, :BPPtr
stb_vorbis_open_memory PROTO C :BPPtr, :SDWORD, :BPPtr, :BPPtr
stb_vorbis_open_pushdata PROTO C :BPPtr, :SDWORD, :BPPtr, :BPPtr, :BPPtr
stb_vorbis_seek PROTO C :BPPtr, :DWORD
stb_vorbis_seek_frame PROTO C :BPPtr, :DWORD
stb_vorbis_seek_start PROTO C :BPPtr
stb_vorbis_stream_length_in_samples PROTO C :BPPtr
stb_vorbis_stream_length_in_seconds PROTO C :BPPtr
