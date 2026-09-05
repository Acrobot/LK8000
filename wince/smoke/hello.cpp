#include <windows.h>

#include <concepts>
#include <span>
#include <string>
#include <vector>

namespace {

template <typename T>
concept Integral = std::integral<T>;

template <Integral T>
T sum(std::span<const T> values) {
  T result{};
  for (const auto value : values) {
    result += value;
  }
  return result;
}

}  // namespace

int WINAPI WinMain(HINSTANCE, HINSTANCE, LPTSTR, int) {
  const std::vector<int> values{1, 2, 3, 4};
  const auto total = sum<int>(values);

  std::wstring message = L"LK8000 WinCE C++20 smoke test: ";
  message += (total == 10) ? L"OK" : L"FAILED";

  MessageBox(nullptr, message.c_str(), L"LK8000-WinCE", MB_OK);
  return total == 10 ? 0 : 1;
}
