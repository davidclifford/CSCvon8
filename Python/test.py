class DevicesImportBase:

    # mutable
    def __init__(self):
        self.field_maps = {'alice': 'meow'}

    # field_maps = {'alice': 'meow'}

    def test1(self):
        self.field_maps = {"fred": "birthday"}
        for field in self.field_maps.items():
            print('1', field)

    def test2(self):
        self.field_maps = {"jake": "fleas"}
        for field in self.field_maps.items():
            print('2', field)

    def test3(self):
        for field in self.field_maps.items():
            print('3', field)


print(DevicesImportBase.__dict__)
print()
dib = DevicesImportBase()
dib.test3()
dib.test1()
print()
dib2 = DevicesImportBase()
dib2.test3()
dib2.test2()
print()
dib.test3()
dib2.test3()
print(DevicesImportBase.__dict__)

