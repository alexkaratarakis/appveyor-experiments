#include <iostream>
#include <zlib.h>

void main()
{
    auto version = zlibVersion();
    std::cout << version;
}
