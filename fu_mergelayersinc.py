"""Merge layers incrementally in GIMP Python-Fu Demo

Run this script from command line as:
gimp -idf --batch-interpreter python-fu-eval -b "import sys;sys.path=['.']+sys.path;import fu_mergelayersinc;fu_mergelayersinc.run('image_file_path', 'layer_base_name')" -b "pdb.gimp_quit(1)"

Replace image_file_path with the full path name of your GIMP image file,
and layer_base_name with the base name of layers to merge.
You can use forward slashes (/) as file separators even in Windows.
"""
import os
import sys
from gimpfu import *


def hide_all_levels(img):
    for layer in img.layers:
        pdb.gimp_item_set_visible(layer, False)


def save_visible_layers(img, file_path):
    """Save visible layers as a PNG file with the given file_path name
    """
    gimp.message('Save: {}'.format(file_path))
    new_image = pdb.gimp_image_duplicate(img)
    merged_layer = pdb.gimp_image_merge_visible_layers(new_image, CLIP_TO_IMAGE)
    pdb.file_png_save(new_image, merged_layer, file_path, file_path, 0, 9, 1, 1, 1, 1, 1)
    pdb.gimp_image_delete(new_image)


def merge_to_png(img, layer_base_name, output_folder):
    """Export to output_folder as PNGs a group of layers selected by their base_name.
    Start hiding all layers, then make them visible one by one
    and export to PNG files whose names are the same as the layers base_name.
    """
    hide_all_levels(img)

    # Select layers on their base_name
    layers = [layer for layer in img.layers if layer_base_name in layer.name]
    n_selected = len(layers)

    # Make selected layers visible one by one
    # and export to PNG
    for l_idx in range(len(layers)):
        # They are listed in reverse order
        # then start from the last element down to the first
        current_layer = layers[n_selected-l_idx-1]
        pdb.gimp_item_set_visible(current_layer, True)
        png_file_path = output_folder + os.sep + current_layer.name + '.png'
        save_visible_layers(img, png_file_path)


def run(image_file_path, layer_base_name):
    """Select a group of layers from image by their base_name,
    then merge them incrementally and export to PNG.
    """
    if not os.path.exists(image_file_path):
        gimp.message('GIMP file not found: {}'.format(image_file_path))
        return

    image_file_folder, image_file_name = os.path.split(image_file_path)
    png_output_folder = image_file_folder + os.sep + 'PNG'

    gimp.message('Load image: {}'.format(image_file_name))
    gimp.message('from {}'.format(image_file_folder))
    img = pdb.gimp_file_load(image_file_path, image_file_path)

    if not os.path.exists(png_output_folder):
        gimp.message('Create output folder: {}'.format(png_output_folder))
        os.makedirs(png_output_folder)
    gimp.message('Merging in {} ...'.format(png_output_folder))
    merge_to_png(img, layer_base_name, png_output_folder)

    # Delete the image from GIMP memory
    # If you're still experiencing memory issues after deleting the image,
    # you may need to check for any remaining layers or channels that are still in memory.
    # You can use the pdb.gimp_image_get_layers function to get a list of all layers in the image,
    # and then delete each layer using pdb.gimp_layer_delete.
    pdb.gimp_image_delete(img)

    gimp.message('Done!')


if __name__ == "__main__":
    print("Running as __main__ with args: {}".format(sys.argv))
