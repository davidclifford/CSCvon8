n = 100
providers = ['A', 'B']

for a in range(n+1):
    distributed_providers = []

    distribution = [a, n-a]
    ds = len(distribution)

    count = distribution[0]
    for i in range(n):
        if count <= 0:
            count += distribution[0]
            distributed_providers.append(providers[1])
        else:
            count -= distribution[1]
            distributed_providers.append(providers[0])

    print(a, n-a, distributed_providers)

