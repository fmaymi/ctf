def plotExplosion ():
    import matplotlib.pyplot as plt
    import numpy as np
    dtype = raw_input('Type of data being plotted: ')
 
    max = raw_input('Name of max value file: ')
    mid = raw_input('Name of middle value file: ')
    loc = raw_input('Name of max location file: ')

    max = np.loadtxt(max)
    mid = np.loadtxt(mid)
    loc = np.loadtxt(loc)

    fig = plt.figure()
    ax1 = fig.add_subplot(311)
    ax2 = fig.add_subplot(312)
    ax3 = fig.add_subplot(313)

    ax1.plot(max[:,0], max[:,1], 'ro')
    ax2.plot(mid[:,0], mid[:,1], 'bo')
    ax3.plot(loc[:,0], loc[:,1], 'go')

    ax1.set_ylabel('Max ' + dtype)
    ax2.set_ylabel('Mid ' + dtype)
    ax3.set_ylabel('Position of Max ' + dtype)
    ax3.set_xlabel('Time')

    fig.savefig("Explosion_" + dtype +'.png')

plotExplosion()

