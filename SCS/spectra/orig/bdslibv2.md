```python
############### BDS Library methods #########################
#    BUSH DIGITAL TELESCOPE SOFTWARE LIBRARY SECTION
#    THIS SECTION CONTAINS LIBRARY METHOD WRIITEN
#    FOR USE BY THE FCSR STUDENTS AS PART OF THE BDS PROJECT
############################################################

#
#    120419 CN v2 "Added function to print BDS parameters"
#    120419 CN v2 “Added function to compute and plot peak spectral wavelengths” 
#    120719 CN v2 "Modified wavelength to color limts"


from IPython.display import HTML
from IPython.display import display



import sys
import math
import time
import picamera
import PIL
from fractions import Fraction
from collections import OrderedDict
from PIL import Image, ImageDraw, ImageFile, ImageFont
from glob import glob
import os, sys
import time
from datetime import datetime
from IPython.core.display import Image, display

# scan a column to determine top and bottom of area of lightness
def get_spectrum_y_bound(pix, x, middle_y, pic_height, spectrum_threshold, spectrum_threshold_duration, adj_top, adj_bot):
    c = 0
    spectrum_top = middle_y
    for y in range(middle_y, 0, -1):
        r, g, b = pix[x, y]
        brightness = r + g + b
        if brightness < spectrum_threshold:
            c = c + 1
            if c > spectrum_threshold_duration:
                break
        else:
            spectrum_top = y
            c = 0

    c = 0
    spectrum_bottom = middle_y
    for y in range(middle_y, pic_height, 1):
        r, g, b = pix[x, y]
        brightness = r + g + b
        if brightness < spectrum_threshold:
            c = c + 1
            if c > spectrum_threshold_duration:
                break
        else:
            spectrum_bottom = y
            c = 0
    print("spectrum_top is %d spectrum bottom is %d" % (spectrum_top, spectrum_bottom))
    spec_adj_top = spectrum_top + adj_top
    spec_adj_bot = spectrum_bottom + adj_bot
    print("adj spectrum_top is %d adj spectrum bottom is %d" % (spec_adj_top, spec_adj_bot))

    #narrow height by cutting off bottom of box
    return spec_adj_top, spec_adj_bot


# find aperture on right hand side of image along middle line
def find_aperture(pic_pixels, pic_width, pic_height, adj_top, adj_bot):
    middle_x = int(pic_width / 2)
#    middle_y = int(pic_height / 2)
    middle_y = int(pic_height * 3/5)
    aperture_brightest = 0
    aperture_x = 0
    for x in range(middle_x, pic_width, 1):
        r, g, b = pic_pixels[x, middle_y]
        brightness = r + g + b
        if brightness > aperture_brightest:
            aperture_brightest = brightness
            aperture_x = x
    print("aperture_x b4 avg is:",aperture_x)

    aperture_threshold = aperture_brightest * 0.9
    aperture_x1 = aperture_x
    for x in range(aperture_x, middle_x, -1):
        r, g, b = pic_pixels[x, middle_y]
        brightness = r + g + b
        if brightness < aperture_threshold:
            aperture_x1 = x
            break
    print("aperture_x1 is:",aperture_x1)
    
    aperture_x2 = aperture_x
    for x in range(aperture_x, pic_width, 1):
        r, g, b = pic_pixels[x, middle_y]
        brightness = r + g + b
        if brightness < aperture_threshold:
            aperture_x2 = x
            break
    print("aperture_x2 is:",aperture_x2)

    aperture_x = (aperture_x1 + aperture_x2) / 2
    print("avg aperture_x is:",aperture_x)
    
    spectrum_threshold_duration = 64
    aperture_y_bounds = get_spectrum_y_bound(pic_pixels, aperture_x, middle_y, pic_height, aperture_threshold, spectrum_threshold_duration, adj_top, adj_bot)
    aperture_y = (aperture_y_bounds[0] + aperture_y_bounds[1]) / 2
    aperture_height = (aperture_y_bounds[1] - aperture_y_bounds[0]) * 1.0

    return {'x': aperture_x, 'y': aperture_y, 'h': aperture_height, 'b': aperture_brightest}


# draw aperture onto image
def draw_aperture(aperture, draw):
    fill_color = "#000"
    draw.line((aperture['x'], aperture['y'] - aperture['h'] / 2, aperture['x'], aperture['y'] + aperture['h'] / 2),
              fill=fill_color)


# draw scan line
def draw_scan_line(aperture, draw, spectrum_angle):
    fill_color = "#888"
    xd = aperture['x']
    h = aperture['h'] / 2
    y0 = math.tan(spectrum_angle) * xd + aperture['y']
    draw.line((0, y0 - h, aperture['x'], aperture['y'] - h), fill=fill_color)
    draw.line((0, y0 + h, aperture['x'], aperture['y'] + h), fill=fill_color)


# return an RGB visual representation of wavelength for chart
# Based on: http://www.efg2.com/Lab/ScienceAndEngineering/Spectra.htm
# The foregoing is based on: http://www.midnightkite.com/color.html
# thresholds = [ 380, 440, 500, 520, 565, 590, 625 ]
#                vio  blu  cyn  gre  yel  org  red
def wavelength_to_color(lambda2):
    factor = 0.0
    color = [0, 0, 0]
    thresholds = [380, 440, 490, 510, 575, 645, 710]

    for i in range(0, len(thresholds) - 1, 1):
        t1 = thresholds[i]
        t2 = thresholds[i + 1]
        if lambda2 < t1 or lambda2 >= t2:
            continue
        if i % 2 != 0:
            tmp = t1
            t1 = t2
            t2 = tmp
        if i < 5:
            color[i % 3] = (lambda2 - t2) / (t1 - t2)
        color[2 - int(i / 2)] = 1.0
        factor = 1.0
        break

    # Let the intensity fall off near the vision limits
    if 380 <= lambda2 < 420:
        factor = 0.2 + 0.8 * (lambda2 - 380) / (420 - 380)
    elif 710 <= lambda2 < 1000:
        factor = 0.2 + 0.8 * (780 - lambda2) / (1000 - 710)
    return int(255 * color[0] * factor), int(255 * color[1] * factor), int(255 * color[2] * factor)

def wavelength_to_rgb(wavelength, gamma=0.8):

    '''This converts a given wavelength of light to an 
    approximate RGB color value. The wavelength must be given
    in nanometers in the range from 380 nm through 750 nm
    (789 THz through 400 THz).

    Based on code by Dan Bruton
    http://www.physics.sfasu.edu/astro/color/spectra.html
    '''

    wavelength = float(wavelength)
    if wavelength >= 380 and wavelength <= 440:
        attenuation = 0.3 + 0.7 * (wavelength - 380) / (440 - 380)
        R = ((-(wavelength - 440) / (440 - 380)) * attenuation) ** gamma
        G = 0.0
        B = (1.0 * attenuation) ** gamma
    elif wavelength >= 440 and wavelength <= 490:
        R = 0.0
        G = ((wavelength - 440) / (490 - 440)) ** gamma
        B = 1.0
    elif wavelength >= 490 and wavelength <= 510:
        R = 0.0
        G = 1.0
        B = (-(wavelength - 510) / (510 - 490)) ** gamma
    elif wavelength >= 510 and wavelength <= 580:
        R = ((wavelength - 510) / (580 - 510)) ** gamma
        G = 1.0
        B = 0.0
    elif wavelength >= 580 and wavelength <= 645:
        R = 1.0
        G = (-(wavelength - 645) / (645 - 580)) ** gamma
        B = 0.0
    elif wavelength >= 645 and wavelength <= 750:
        attenuation = 0.3 + 0.7 * (750 - wavelength) / (750 - 645)
        R = (1.0 * attenuation) ** gamma
        G = 0.0
        B = 0.0
    else:
        R = 0.0
        G = 0.0
        B = 0.0
    R *= 255
    G *= 255
    B *= 255
    return (int(R), int(G), int(B))

def take_spectrum(name, shutter):
    try:
        os.remove("capture_lockfile")
    except OSError:
            pass
    camera = picamera.PiCamera()
    try:
        print("allowing camera to warmup")
        camera.vflip = True
        camera.hflip = True
        camera.framerate = Fraction(1, 2)
        camera.shutter_speed = shutter
        camera.iso = 100
        camera.exposure_mode = 'off'
        camera.awb_mode = 'off'
        camera.awb_gains = (1, 1)
        time.sleep(3)
        print("capturing image")
        camera.capture(name, resize=(1296, 972))
    finally:
        camera.close()
        print("closing camera")
        os.mknod("capture_lockfile")
    return name

def determine_shutter(name, guess_shutter, ntrials):
    print("trying with increasing shutter speeds")
    shutter_speeds = []

    for trial in range(1,ntrials+1):
        shutter_speeds.append(guess_shutter * trial) 
        
    for trial in range(1,ntrials+1):
        try:
            os.remove("capture_lockfile")
        except OSError:
                pass
        camera = picamera.PiCamera()
        try:
            print("allowing camera to warmup")
            camera.vflip = True
            camera.hflip = True
            camera.framerate = Fraction(1, 2)
            camera.shutter_speed = shutter_speeds[trial-1]
            camera.iso = 100
            camera.exposure_mode = 'off'
            camera.awb_mode = 'off'
            camera.awb_gains = (1, 1)
            time.sleep(3)
            print("capturing image at shutter speed %d" % shutter_speeds[trial-1])
            camera.capture(name + "_" + str(trial) + ".jpg", resize=(1296, 972))
        finally:
            camera.close()
            print("closing camera")
            os.mknod("capture_lockfile")

    return shutter_speeds

def getSize(filename):
    if os.path.isfile(filename): 
        st = os.stat(filename)
        return st.st_size
    else:
        return -1

def wait_capture(file_path):
    time_to_wait = 10
    time_counter = 0
    while not os.path.exists(file_path):
        time.sleep(1)
        time_counter += 1
        if time_counter > time_to_wait:
            break

def draw_graph(draw, pic_pixels, aperture, spectrum_angle, wavelength_factor):
    aperture_height = aperture['h'] / 2
    step = 1
    last_graph_y = 0
    max_result = 0
    results = OrderedDict()
    for x in range(0, int(aperture['x'] * 7 / 8), step):
        wavelength = (aperture['x'] - x) * wavelength_factor
        if 1000 < wavelength or wavelength < 380:
            continue

        # general efficiency curve of 1000/mm grating
        eff = (800 - (wavelength - 250)) / 800
        if eff < 0.3:
            eff = 0.3

        # notch near yellow maybe caused by camera sensitivity
        mid = 571
        width = 14
        if (mid - width) < wavelength < (mid + width):
            d = (width - abs(wavelength - mid)) / width
            eff = eff * (1 - d * 0.12)

        # up notch near 590
        #mid = 588
        #width = 10
        #if (mid - width) < wavelength < (mid + width):
        #    d = (width - abs(wavelength - mid)) / width
        #    eff = eff * (1 + d * 0.1)

        y0 = math.tan(spectrum_angle) * (aperture['x'] - x) + aperture['y']
        amplitude = 0
        ac = 0.0
        for y in range(int(y0 - aperture_height), int(y0 + aperture_height), 1):
            r, g, b = pic_pixels[x, y]
            q = r + b + g * 2
            if y < (y0 - aperture_height + 2) or y > (y0 + aperture_height - 3):
                q = q * 0.5
            amplitude = amplitude + q
            ac = ac + 1.0

        amplitude = amplitude / ac / eff
        # amplitude=1/eff
        results[str(wavelength)] = amplitude
        if amplitude > max_result:
            max_result = amplitude
        graph_y = amplitude / 50 * aperture_height
        draw.line((x - step, y0 + aperture_height - last_graph_y, x, y0 + aperture_height - graph_y), fill="#fff")
        last_graph_y = graph_y
    draw_ticks_and_frequencies(draw, aperture, spectrum_angle, wavelength_factor)
    return results, max_result


def draw_ticks_and_frequencies(draw, aperture, spectrum_angle, wavelength_factor):
    aperture_height = aperture['h'] / 2
    for wl in range(400, 1001, 50):
        x = aperture['x'] - (wl / wavelength_factor)
        y0 = math.tan(spectrum_angle) * (aperture['x'] - x) + aperture['y']
        draw.line((x, y0 + aperture_height + 5, x, y0 + aperture_height - 5), fill="#fff")
        font = ImageFont.truetype('/usr/share/fonts/truetype/lato/Lato-Regular.ttf', 12)
        draw.text((x, y0 + aperture_height + 15), str(wl), font=font, fill="#fff")


def inform_user_of_exposure(max_result):
    exposure = max_result / (255 + 255 + 255)
    print("ideal exposure between 0.15 and 0.30")
    print("exposure=", exposure)
    if exposure < 0.15:
        print("consider increasing shutter time\n")
    elif exposure > 0.3:
        print("consider reducing shutter time\n")


def save_image_with_overlay(im, name):
    output_filename = name
    ImageFile.MAXBLOCK = 2 ** 20
    im.save(output_filename, "JPEG", quality=80, optimize=True, progressive=True)


def normalize_results(results, max_result):
    for wavelength in results:
        results[wavelength] = results[wavelength] / max_result
    return results


def export_csv(name, normalized_results):
    csv_filename = name + ".csv"
    csv = open(csv_filename, 'w')
    csv.write("wavelength,amplitude\n")
    for wavelength in normalized_results:
        csv.write(wavelength)
        csv.write(",")
        csv.write("{:0.3f}".format(normalized_results[wavelength]))
        csv.write("\n")
    csv.close()


def export_diagram(name, normalized_results):
    antialias = 4
    w = 600 * antialias
    h2 = 300 * antialias

    h = h2 - 20 * antialias
    sd = PIL.Image.new('RGB', (w, h2), (255, 255, 255))
    draw = PIL.ImageDraw.Draw(sd)

    w1 = 380.0
    w2 = 1000.0
    f1 = 1.0 / w1
    f2 = 1.0 / w2
    for x in range(0, w, 1):
        # Iterate across frequencies, not wavelengths
        lambda2 = 1.0 / (f1 - (float(x) / float(w) * (f1 - f2)))
#        c = wavelength_to_color(lambda2)
        c = wavelength_to_rgb(lambda2)
        draw.line((x, 0, x, h), fill=c)

    pl = [(w, 0), (w, h)]
    for wavelength in normalized_results:
        wl = float(wavelength)
        x = int((wl - w1) / (w2 - w1) * w)
        # print wavelength,x
        pl.append((int(x), int((1 - normalized_results[wavelength]) * h)))
    pl.append((0, h))
    pl.append((0, 0))
    draw.polygon(pl, fill="#FFF")
    draw.polygon(pl)

    font = PIL.ImageFont.truetype('/usr/share/fonts/truetype/lato/Lato-Regular.ttf', 12 * antialias)
    draw.line((0, h, w, h), fill="#000", width=antialias)

    for wl in range(380, 1000+1, 10):
        x = int((float(wl) - w1) / (w2 - w1) * w)
        draw.line((x, h, x, h + 3 * antialias), fill="#000", width=antialias)

    for wl in range(380, 1000+1, 50):
        x = int((float(wl) - w1) / (w2 - w1) * w)
        draw.line((x, h, x, h + 5 * antialias), fill="#000", width=antialias)
        wls = str(wl)
        tx = draw.textsize(wls, font=font)
        draw.text((x - tx[0] / 2, h + 5 * antialias), wls, font=font, fill="#000")

    # save chart
    sd = sd.resize((int(w / antialias), int(h / antialias)), PIL.Image.ANTIALIAS)
    output_filename = name
    sd.save(output_filename, "PNG", quality=95, optimize=True, progressive=True)


def display_image_in_actual_size(im_path):
    import matplotlib as mpl

    dpi = mpl.rcParams['figure.dpi']
    im_data = plt.imread(im_path)
    height, width, depth = im_data.shape

    # What size does the figure need to be in inches to fit the image?
    figsize = width / float(dpi), height / float(dpi)

    # Create a figure of the right size with one axes that takes up the full figure
    fig = plt.figure(figsize=figsize)
    ax = fig.add_axes([0, 0, 1, 1])

    # Hide spines, ticks, etc.
    ax.axis('off')

    # Display the image.
    ax.imshow(im_data, cmap='gray')

    plt.show()
    
    

```


```python
import pandas as pd
import numpy
import peakutils
from peakutils.plot import plot as pplot
from matplotlib import pyplot
%matplotlib inline

def display_bds_params(name,desc,shutter,slit_topadj,slit_botadj,spectrum_angle,wavelength_factor,samp_th,wlen_th):
    print("Title:\t\t", desc.upper())
    print("BDS parameters used for this run:")
    print("Spectrum Base Name is          \t", name)
    print("Camera Shutter is:             \t", shutter)
    print("Slit Top Adjustment is:        \t", slit_topadj)
    print("Slit Bottom Adjustment is:     \t", slit_botadj)
    print("Camera Spectrum Angle is:      \t", spectrum_angle)
    print("Camera Wavelength Factor is:   \t", wavelength_factor)
    print("Amplitude Threshold is:        \t", samp_th)
    print("Wavelength Threshold is:       \t", wlen_th)
    
def write_bds_params(fnametxt,name,desc,shutter,slit_topadj,slit_botadj,spectrum_angle,wavelength_factor,samp_th,wlen_th):
    fname = open(fnametxt, 'w')
    print("Title:\t\t", desc.upper(), file=fname)
    print("BDS parameters used for this run:", name, file=fname)
    print("Spectrum Base Name is          \t", name, file=fname)
    print("Camera Shutter is:             \t", shutter, file=fname)
    print("Slit Top Adjustment is:        \t", slit_topadj, file=fname)
    print("Slit Bottom Adjustment is:     \t", slit_botadj, file=fname)
    print("Camera Spectrum Angle is:      \t", spectrum_angle, file=fname)
    print("Camera Wavelength Factor is:   \t", wavelength_factor, file=fname)
    print("Amplitude Threshold is:        \t", samp_th, file=fname)
    print("Wavelength Threshold is:       \t", wlen_th, file=fname)

def draw_spectral_line_peaks(element,name,fnamepng,desc,samp_th,wlen_th):
    sdf = pd.read_csv(name)
    fig = pyplot.figure(figsize=(10,6))
    x = sdf['wavelength']
    y = sdf['amplitude']
    peaks = peakutils.indexes(y, thres=samp_th, min_dist=wlen_th)
    peak_wavelength_list = ""
    for i in reversed(peaks):
        peak_wavelength_list += (str("%3.0f " % x[i]))

    #print(peak_wavelength_list)
    t1="THE MEASURED PEAK WAVELENGTHS FOR {} IN NANO_METERS ARE: {}".format(element.upper(), peak_wavelength_list)
    if   element.lower() == 'argon':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'750 763 794 810')
    elif element.lower() == 'helium':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'587 668 706 728')
    elif element.lower() == 'hydrogen':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'486 656')
    elif element.lower() == 'krypton':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'811 828 850 877')
    elif element.lower() == 'mercury':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'404 436 546')
    elif element.lower() == 'neon':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'585 607 615 626 640 837 865 878')
    elif element.lower() == 'nitrogen':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'745 868')
    elif element.lower() == 'terbium':
        t2="THE NIST STANDARD STRONG LINE WAVELENGTHS FOR {} ARE: {}".format(element.upper(),'432 535')
    else:
        t2 = "THE NIST STANDARD STRONG LINE WAVELENGTHS DO NOT EXIST FOR THIS ELEMENT!"
 
    #print(t1)
    #print(t2)
    
    pyplot.title('SPECTRAL PEAK WAVELENGTHS FOR '+element.upper()+'\n'+t1+'\n'+t2)
    pplot(x, y, peaks)
    fig.savefig(fnamepng,bbox_inches='tight')

    return peak_wavelength_list, t1, t2    
```


```python

```
