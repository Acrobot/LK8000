#pragma once

#include <errno.h>

/*
 * Pocket PC 2003's CRT as exposed by cegcc does not provide the normal
 * strerror() declaration/implementation expected by current zziplib.
 * zzip only uses it to turn OS-level failures into diagnostic text, so a
 * small C-locale mapping is sufficient and avoids pulling in desktop CRT
 * assumptions.
 */
static inline const char* zzip_wince_strerror(int errnum) {
  switch (errnum) {
    case 0:
      return "No error";
#ifdef EACCES
    case EACCES:
      return "Permission denied";
#endif
#ifdef EBADF
    case EBADF:
      return "Bad file descriptor";
#endif
#ifdef EEXIST
    case EEXIST:
      return "File exists";
#endif
#ifdef EFAULT
    case EFAULT:
      return "Bad address";
#endif
#ifdef EINVAL
    case EINVAL:
      return "Invalid argument";
#endif
#ifdef EIO
    case EIO:
      return "I/O error";
#endif
#ifdef ENOENT
    case ENOENT:
      return "No such file or directory";
#endif
#ifdef ENOMEM
    case ENOMEM:
      return "Out of memory";
#endif
#ifdef ENOSPC
    case ENOSPC:
      return "No space left on device";
#endif
    default:
      return "WinCE error";
  }
}

#define strerror zzip_wince_strerror
