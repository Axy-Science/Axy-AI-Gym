#include <bits/stdc++.h>
using namespace std;

static const int MAXN = 100000001;
static bitset<MAXN> composite;

static char buf[1 << 23];
static int bufPos = 0;

void flush() {
    fwrite(buf, 1, bufPos, stdout);
    bufPos = 0;
}

void writeInt(int x) {
    char tmp[12];
    int len = 0;
    while (x > 0) {
        tmp[len++] = '0' + x % 10;
        x /= 10;
    }
    for (int i = len - 1; i >= 0; i--)
        buf[bufPos++] = tmp[i];
    buf[bufPos++] = '\n';
    if (bufPos > (1 << 23) - 20)
        flush();
}

int main() {
    int n;
    scanf("%d", &n);

    composite[0] = composite[1] = 1;
    for (int i = 2; i * i < MAXN; i++) {
        if (!composite[i]) {
            for (int j = i * i; j < MAXN; j += i)
                composite[j] = 1;
        }
    }

    if (n > 1)
        writeInt(1);

    for (int i = 2; i < n; i++) {
        if (!composite[i])
            writeInt(i);
    }

    if (bufPos > 0)
        flush();

    return 0;
}
