#!/usr/bin/perl

use Image::Magick;

$image= Image::Magick->new;
$image->Read('png:/usr/local/shakecast/sc/images/citygrey.png');
$image->Resize(geometry=>'50%');
$image->Write('png:/usr/local/shakecast/sc/util/city.png');

$magick= Image::Magick->new;
$magick->Set(size=>'256x256');
$magick->ReadImage('xc:purple');
$magick->Transparent(color=>'purple');
$magick->Composite(image=>$image, compose=>'Over', x=>30, y=>30, geometry=>'50%');
$magick->Set(quality=>100);
$magick->Write('png:/usr/local/shakecast/sc/util/test.png');

exit;
