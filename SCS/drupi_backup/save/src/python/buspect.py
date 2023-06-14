import spectlibs
from PIL import Image, ImageDraw, ImageFile, ImageFont

def take_and_analyze:
	if  cmd == "take":
		spectlibs.take_picture(raw_filename,shutter)
	
	elif cmd == "process":
		# 2. Get picture's aperture
		im = Image.open(raw_filename)
		print("locating aperture")
		pic_pixels = im.load()
		aperture = spectlibs.find_aperture(pic_pixels, im.size[0], im.size[1])
	
		# 3. Draw aperture and scan line
		spectrum_angle = -0.01
		draw = spectlibs.ImageDraw.Draw(im)
		spectlibs.draw_aperture(aperture, draw)
		spectlibs.draw_scan_line(aperture, draw, spectrum_angle)
	
		# 4. Draw graph on picture
		print("analyzing image")
		wavelength_factor = 0.95
		#wavelength_factor = 0.892  # 1000/mm
		#wavelength_factor=0.892*2.0*600/650 # 500/mm
		results, max_result = spectlibs.draw_graph(draw, pic_pixels, aperture, spectrum_angle, wavelength_factor)
	
		# 5. Inform user of issues with exposure
		spectlibs.inform_user_of_exposure(max_result)

def save_export:


# 1. Take picture
name = "temp"
cmd = "take"
shutter = 100000

raw_filename = name + "_raw.jpg"


	# 6. Save picture with overlay
	save_image_with_overlay(im, name)

	# 7. Normalize results for export
	print("exporting CSV")
	normalized_results = normalize_results(results, max_result)

	# 8. Save csv of results
	export_csv(name, normalized_results)

	# 9. Generate spectrum diagram
	print("generating chart")
	export_diagram(name, normalized_results)

else:
	print("wrong cmd")           
