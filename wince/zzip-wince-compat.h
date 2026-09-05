#pragma once

#include <errno.h>

/*
 * zziplib's internal fallback helpers use both spellings below. Its checked-in
 * MSVC config only defines _zzip_restrict; on the cegcc/WinCE C frontend the
 * other spelling is therefore parsed as an identifier in a parameter list.
 */
#ifndef _zzip_restrict
#define _zzip_restrict
#endif
#ifndef __zzip_restrict
#define __zzip_restrict
#endif

/*
 * WinCE's C runtime has no POSIX strcasecmp().  Avoid zziplib's fallback here:
 * that fallback currently has a non-const function signature and also assumes
 * tolower() has been declared. ZIP entry names used by LK8000 are ASCII, so a
 * locale-independent ASCII comparison is sufficient and has the same const
 * signature as strcmp().
 */
static inline unsigned char zzip_wince_ascii_lower(unsigned char ch) {
  return (ch >= 'A' && ch <= 'Z') ? (unsigned char)(ch + ('a' - 'A')) : ch;
}

static inline int zzip_wince_strcasecmp(const char* a, const char* b) {
  if (!a)
    return b ? -1 : 0;
  if (!b)
    return 1;

  while (*a && *b) {
    const unsigned char ca = zzip_wince_ascii_lower((unsigned char)*a);
    const unsigned char cb = zzip_wince_ascii_lower((unsigned char)*b);
    if (ca != cb)
      return (int)ca - (int)cb;
    ++a;
    ++b;
  }

  return (int)zzip_wince_ascii_lower((unsigned char)*a) -
         (int)zzip_wince_ascii_lower((unsigned char)*b);
}

#define strcasecmp zzip_wince_strcasecmp

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
