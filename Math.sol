// Submitted by EthereumHistory (ethereumhistory.com)

contract Math {
    address creator;

    function MarketsContract() {
        creator = msg.sender;
    }

    function changeCreator(address newCreator) {
        if (creator == msg.sender) creator = newCreator;
    }

    function deleteContract() {
        if (creator == msg.sender) suicide(msg.sender);
    }

    function e_exp(uint x) constant returns (uint) {
        uint ln2 = 12786308645202655660;
        uint quot = x * 2**64 / ln2;
        uint mult = 2 ** (quot / 2**64);
        uint r = quot % 2**64;
        uint xk = r;
        uint acc = 2**64;

        acc = acc + 12786308848809676358 * xk / 2**64;
        xk = xk * r / 2**64;
        acc = acc + 4431393213333354933 * xk / 2**64;
        xk = xk * r / 2**64;
        acc = acc + 1023895807607063857 * xk / 2**64;
        xk = xk * r / 2**64;
        acc = acc + 177331293418178780 * xk / 2**64;
        xk = xk * r / 2**64;
        acc = acc + 24779311982669544 * xk / 2**64;
        xk = xk * r / 2**64;
        acc = acc + 2636551292259273 * xk / 2**64;

        acc = acc + 97423649007;

        return mult * acc;
    }

    function ln(uint x) constant returns (uint) {
        uint log2_e = 26613026195688644983;
        uint log2x = floor_log2(x);
        uint mant = x / 2**log2x;
        uint pow = 2**64;
        uint k = 2**64 * uint(10);
        uint acc = k;

        acc = acc - 78667125315852878943 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 277444915915471133247 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 672797865977353252899 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 1342495486912798362956 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 2079982050276078403724 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 2513117219478940937138 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 2388947274873244002805 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 1796495340862302170357 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 1069452193429189189773 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 501541584095099868767 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 183176043153313066814 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 51045426652184553460 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 10488088993333923171 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 1498020070724751224 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc - 132863869502364569 * pow / 2**64;
        pow = pow * mant / 2**64;
        acc = acc + 5511900345305548 * pow / 2**64;

        return ((log2x * 2**64 + acc) - k) * 2**64 / log2_e;
    }

    function floor_log2(uint x) constant returns (uint) {
        uint v = x / 2**64;
        uint lo = 0;
        uint hi = 191;
        uint mid = (hi + lo) / 2;
        while (lo + 1 != hi) {
            if (v < 2**mid) hi = mid;
            else lo = mid;
            mid = (hi + lo) / 2;
        }
        return lo;
    }
}
