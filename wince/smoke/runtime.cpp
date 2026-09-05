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
  const std::wstring marker = L"LK8000-WinCE";

  // Keep this test headless so an emulator can execute it unattended.
  // Returning zero proves that WinMain, libstdc++ containers/strings and
  // C++20 concepts/span all made it through the WinCE runtime successfully.
  return total == 10 && marker.size() == 12 ? 0 : 1;
}
