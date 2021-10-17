class Float:
    mantissa = 0
    exponent = 0

    def __init__(self, mant, exp):
        self.mantissa = mant
        self.exponent = exp

    def raw(self):
        print('%fx10^%d' % (self.mantissa, self.exponent))

    def out(self):
        x = self.mantissa * 10**self.exponent
        print(x)

    def add(self, f):
        e1 = self.exponent
        e2 = f.exponent
        m1 = self.mantissa
        m2 = f.mantissa

        e = 0
        if e1 > e2:
            e = e1
            m = m2 / 10**(e1-e2) + m1
        elif e1 == e2:
            e = e1
            m = m1 + m2
        else:
            e = e2
            m = m1 / 10**(e2-e1) + m2

        if m > 1.0:
            e += 1
            m = m/10

        return Float(m, e)

    def mult(self, f):
        e1 = self.exponent
        e2 = f.exponent
        m1 = self.mantissa
        m2 = f.mantissa

        e = 0
        e = e1 + e2
        m = m1 * m2
        while m > 1.0:
            e += 1
            m = m / 10.0
        while m < 0.1:
            e -= 1
            m = m * 10.0

        return Float(m, e)


f1 = Float(0.2, 3)
f2 = Float(0.25, 1)

f1.raw()
f2.raw()
print()
f1.out()
f2.out()

f3 = f1.add(f2)
print()
f3.raw()
f3.out()

f4 = f1.mult(f2)
print()
f4.raw()
f4.out()




