import scipy.optimize
import numpy as np
"""
Functions to fit and plota resonance
"""
def mazinResonance(x, q, f0, a, v, c, theta, gi, gq, ic, qc):
    """
    Parametrization from Ben Mazin's Thesis.
    
    x is frequency
    q, f0, a, v, c, theta, gi, gq, ic, qc are the parameters
    """
    dx = (x-f0)/f0
    z = (2*q*dx)*1j
    f = (z/(1+z))
    f -= 0.5 
    f += c*dx 
    temp = np.exp(v*dx*1j)
    temp = 1-temp
    temp = a*temp
    f += temp
    f1 = gi*f.real + gq*(1j)*f.imag
    f2 = f1 * np.exp((1j)*theta)
    f3 = f2 + (ic + (1j)*qc)
    retval = np.array([np.real(f3), np.imag(f3)]).reshape((-1))
    return retval

def firstGuess(fl, iqs):
    """
    Make a rough estimate of the parameters based on frequency,iq values
    """
    il = np.real(iqs)
    ql = np.imag(iqs)
    fa = np.array(fl)
    ia = np.array(il)
    qa = np.array(ql)
    # The gains are the diameter of the loop
    gi = ia.max() - ia.min()
    gq = qa.max() - qa.min()
    # The center of the loop is the average of the min,max values
    ic = 0.5*(ia.max()+ia.min()) # or ia.mean()
    qc = 0.5*(qa.max()+qa.min()) # qa.mean()
    
    # get fc from the iq velocity vs frequency
    dia = ia[:-1]-ia[1:]
    dqa = qa[:-1]-qa[1:]
    iqv = np.sqrt(dia*dia+dqa*dqa)
    ff = 0.5*(fa[:-1]+fa[1:])
    try:
        fc = np.average(ff, weights=iqv)
    except ZeroDivisionError:
        fc = np.average(ff)
    # get the STD of the resonance peak; define q = fc/std (what about that factor of 2.something?)
    fmfc = ff-fc
    fmfc2 = fmfc**2
    var = np.average(fmfc2, weights=iqv)
    std = np.sqrt(var)
    q = fc/std
    
    # calculate theta.  Get average of ia and qa, weighted by iq velocity
    iaInterp = np.interp(ff, fa, ia)
    qaInterp = np.interp(ff, fa, qa)    
    wia = np.average(iaInterp, weights=iqv)
    wqa = np.average(qaInterp, weights=iqv)
    dx = wia-ic
    dy = wqa-qc
    
    theta = np.pi/2.0 + np.arctan2(dx, -dy)
    if theta < 0:
        theta += 2.0*np.pi
    #tl = 90+np.arctan2(xl, -yl)*180/np.pi
    #tl = np.where(tl>=0, tl, tl+360)

    a= 1 # Not bad for a starting point
    v = 1000 
    c = 1000
    return q,fc,a,v,c,theta,gi,gq,ic,qc

def fitResonance(freqs, iqs):
    """
    fit the resonance.  
    
    Returns the result of scipy.optimize.curve_fit
    
    The parameters are the first element in the order used by mazinResonance.
    
    So, for example, the fit frequency is rv[0][1]
    """
    p0 = firstGuess(freqs, iqs)
    iqsF = np.array([np.real(iqs), np.imag(iqs)]).reshape((-1))
    rv = scipy.optimize.curve_fit(mazinResonance, freqs, iqsF, p0)
    return rv
def fitResonancePlot(freqs, iqs, p, iPlot):
    """
    See how the fit matches the data. iPlot=0 is a Bode plot; iPlot=1 is IQ plot
    """
    import matplotlib.pyplot as plt
    fMid = np.mean(freqs)
    fitFreqs = np.linspace(freqs.min(),freqs.max(),100)
    iqFitF = mazinResonance(fitFreqs, *p)
    iqFit = iqFitF.reshape((2,-1))[0] + 1j*iqFitF.reshape((2,-1))[1]
    if iPlot == 0: # Bode plot
        fig, ax = plt.subplots(2,1,sharex=True)
        ax[0].plot(freqs-fMid, np.abs(iqs),'.')
        ax[0].plot(fitFreqs-fMid, np.abs(iqFit))
        ax[1].plot(freqs-fMid, np.angle(iqs),'.')
        ax[1].plot(fitFreqs-fMid, np.angle(iqFit))
        plt.xlabel("Frequency - %.1f"%fMid)
    elif iPlot == 1: # IQ plot
        plt.plot(np.real(iqs),np.imag(iqs),'.')
        plt.plot(np.real(iqFit),np.imag(iqFit))
    plt.suptitle("f0 = %f"%p[1])

