"
An ImageFormTest is a test class for testing the behavior of ImageForm
"
Class {
	#name : #ImageFormTest,
	#superclass : #TestCase,
	#category : #'Image-Form-test'
}

{ #category : #test }
ImageFormTest >> formClass [
	^ Form
]

{ #category : #test }
ImageFormTest >> imageFormClass [
	^ ImageForm
]

{ #category : #test }
ImageFormTest >> testApplyKernel [
	"Apply convolution to a image using a Identity Kernel. The image should not be changed"

	| anImage anImageKernel anIdentityKernel |
	anImage := self imageFormClass
		newFrom: (self formClass extent: 50 @ 50 depth: 32).
	anImage fillColor: Color red.
	anIdentityKernel := {{0 . 0 . 0}.
	{0 . 1 . 0}.
	{0 . 0 . 0}}.
	anImageKernel := anImage applyKernel: anIdentityKernel flattened.
	self assertCollection: anImage bits equals: anImageKernel bits
]

{ #category : #test }
ImageFormTest >> testAsGrayScale [
	"Covert a image in GrayScale. The color in position 0,0 should be changed"

	| aForm aGrayImage aImage |
	aForm := self formClass extent: 10 @ 10 depth: 32.
	aImage := self imageFormClass newFrom: aForm.
	aImage fillColor: Color red.
	aGrayImage := aImage asGrayScale.
	self
		assert: (aGrayImage colorAt: 0 @ 0)
		equals:
			(Color
				r: 0.211
				g: 0.211
				b: 0.211
				alpha: 1.0).
	self assert: (aImage colorAt: 0 @ 0) equals: Color red
]

{ #category : #test }
ImageFormTest >> testAsGrayScaleWithAlpha [
	"Covert a image in GrayScale. The color in position 0,0 should be changed"

	| aForm aGrayImage aImage |
	aForm := self formClass extent: 10 @ 10 depth: 32.
	aImage := self imageFormClass newFrom: aForm.
	aImage
		fillColor:
			(Color
				r: 1
				g: 0
				b: 0
				alpha: 0.2).
	aGrayImage := aImage asGrayScaleWithAlpha.
	self
		assert: (aGrayImage colorAt: 0 @ 0)
		equals:
			(Color
				r: 0.211
				g: 0.211
				b: 0.211
				alpha: 0.2).
	self
		assert: (aImage colorAt: 0 @ 0)
		equals:
			(Color
				r: 1
				g: 0
				b: 0
				alpha: 0.2)
]

{ #category : #test }
ImageFormTest >> testCropHW [
	"crop a imageTest. The color of the image should be all blue"

	| aImage aCroppedImage |
	aImage := self imageFormClass imageTest.
	aCroppedImage := aImage crop: 0 @ 0 h: 50 w: 50.
	self assert: aCroppedImage shape equals: '50X50'.
	self assert: aImage shape equals: '100X100'.
	self assert: aCroppedImage colorsUsed equals: {Color blue}
]

{ #category : #test }
ImageFormTest >> testFlipHorizontally [
	"Flip horizontally the imageTest.  The color in position 0,0 should be changed"

	| aImage aImageFlipped |
	aImage := self imageFormClass imageTest.
	aImageFlipped := aImage flipHorizontally.
	self assert: (aImageFlipped colorAt: 0 @ 0) equals: Color red.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue
]

{ #category : #test }
ImageFormTest >> testFlipVertically [
	"Flip vertically the imageTest. The color in position 0,0 should be changed"

	| aImage aImageFlipped |
	aImage := self imageFormClass imageTest.
	aImageFlipped := aImage flipVertically.
	self assert: (aImageFlipped colorAt: 0 @ 0) equals: Color green.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue
]

{ #category : #test }
ImageFormTest >> testGetNeighborhoodKernel [
	"Apply convolution to a point using a Identity Kernel. The result color should not be chaged "

	| aForm aImage aPixelColor |
	aForm := self formClass extent: 100 @ 100 depth: 32.
	aImage := self imageFormClass newFrom: aForm.
	aImage fillColor: Color red.
	aPixelColor := aImage
		getNeighborhood: 0 @ 0
		kernel: {0 . 0 . 0 . 0 . 1 . 0 . 0 . 0 . 0}.
	self assert: aPixelColor equals: Color red
]

{ #category : #test }
ImageFormTest >> testGetPointNeighborhoodKsize [
	"Get a Neighbordhood of a point, with an image (3x3). should be return an expected list of points."

	| aForm aImage neighborhood |
	aForm := self formClass extent: 3 @ 3 depth: 32.
	aImage := self imageFormClass newFrom: aForm.
	aImage fillColor: Color red.
	neighborhood := aImage getPointNeighborhood: 0 @ 0 ksize: 3 @ 3.
	self
		assertCollection: neighborhood
		hasSameElements:
			{(0 @ 0).
			(0 @ 0).
			(0 @ 1).
			(0 @ 0).
			(0 @ 0).
			(0 @ 1).
			(1 @ 0).
			(1 @ 0).
			(1 @ 1)} asOrderedCollection.
	neighborhood := aImage getPointNeighborhood: 1 @ 1 ksize: 3 @ 3.
	self
		assertCollection: neighborhood
		hasSameElements:
			{(0 @ 0).
			(0 @ 1).
			(0 @ 2).
			(1 @ 0).
			(1 @ 1).
			(1 @ 2).
			(2 @ 0).
			(2 @ 1).
			(2 @ 2)} asOrderedCollection.
	neighborhood := aImage getPointNeighborhood: 2 @ 2 ksize: 3 @ 3.
	self
		assertCollection: neighborhood
		hasSameElements:
			{(1 @ 1).
			(1 @ 2).
			(1 @ 2).
			(2 @ 1).
			(2 @ 2).
			(2 @ 2).
			(2 @ 1).
			(2 @ 2).
			(2 @ 2)} asOrderedCollection
]

{ #category : #test }
ImageFormTest >> testLighter [
	"ligter an black image in 1. The result should be an white image"

	| aImage aImageLightered |
	aImage := self imageFormClass
		newFrom: (self formClass extent: 50 @ 50 depth: 32).
	aImage fillColor: Color black.
	aImageLightered := aImage lighter: 1.
	self
		assert: (aImageLightered colorAt: 0 @ 0)
		equals:
			(Color
				r: 1.0
				g: 0.995
				b: 0.995
				alpha: 1.0)
]

{ #category : #test }
ImageFormTest >> testOpen [
	"Save an image in the imageDirectory and Open it. The image should be the same. Before exit remove the image."

	| aImage aPath aImageSave |
	aPath := FileLocator imageDirectory fullPath pathString
		, '/test_image.png'.
	aImage := self imageFormClass imageTest.
	aImage save: aPath.
	aImageSave := self imageFormClass open: aPath.
	self assert: aImage bits equals: aImageSave bits.
	(FileLocator imageDirectory / 'test_image.png') delete.
	self
		should: [ self imageFormClass open: 'estonoexiste.jpg' ]
		raise: Error
]

{ #category : #test }
ImageFormTest >> testRotateBy [
	"Using the ImageForm imageTest. Rotate in three degress. The color in position 0,0 should be changed"

	| aImage aImageRotated |
	aImage := self imageFormClass imageTest.
	aImageRotated := aImage rotateBy: 90.
	self assert: (aImageRotated colorAt: 100 @ 100) equals: Color red.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue.
	
	aImageRotated := aImage rotateBy: 180.
	self assert: (aImageRotated colorAt: 100 @ 100) equals: Color blue.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue.
	
	aImageRotated := aImage rotateBy: 360.
	self assert: (aImageRotated colorAt: 100 @ 100) equals: Color yellow.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue
]

{ #category : #test }
ImageFormTest >> testRotateBycenterAt [
	"Using the ImageForm imageTest. Rotate in three directions. The color in position 0,0 should be changed"

	| aImage aImageRotated |
	aImage := self imageFormClass imageTest.
	aImageRotated := aImage rotateBy: #left centerAt: 0 @ 0.
	self assert: (aImageRotated colorAt: 0 @ 0) equals: Color red.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue.
	aImageRotated := aImage rotateBy: #right centerAt: 0 @ 0.
	self assert: (aImageRotated colorAt: 0 @ 0) equals: Color green.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue.
	aImageRotated := aImage rotateBy: #pi centerAt: 0 @ 0.
	self assert: (aImageRotated colorAt: 0 @ 0) equals: Color yellow.
	self assert: (aImage colorAt: 0 @ 0) equals: Color blue
]

{ #category : #test }
ImageFormTest >> testSave [
	"Save an image in the imageDirectory. The image should exist. Before exit remove the image."

	| aImage aPath |
	aPath := FileLocator imageDirectory fullPath pathString , '/test.png'.
	aImage := self imageFormClass imageTest.
	aImage save: aPath.
	self assert: (FileLocator imageDirectory / 'test.png') exists.
	(FileLocator imageDirectory / 'test.png') delete
]

{ #category : #test }
ImageFormTest >> testScaledHeight [
	"Scaled an image in height 50 and width 50. The result should be a image with shape 50x25"

	| aImage aImageScaled |
	aImage := self imageFormClass newFrom: (Form extent: 100 @ 50).
	aImageScaled := aImage scaled: 50 height: 50.
	self assert: aImageScaled shape equals: '50X25'
]

{ #category : #test }
ImageFormTest >> testScaledIntoFormOfSize [
	"Scaled an image in height 20 and width 20. The result should be a image with shape 20x20 "

	| aImage aImageScaled |
	aImage := self imageFormClass newFrom: (Form extent: 100 @ 300).
	aImageScaled := aImage scaledIntoFormOfSize: 20.
	self assert: aImageScaled shape equals: '20X20'
]

{ #category : #test }
ImageFormTest >> testShape [
	"Create an Image with height 100 and width 100. The result should be a string with value 100x100"
	
	| aImage |
	aImage := self imageFormClass newFrom: (self formClass extent: 100@100).
	self assert: aImage shape equals: '100X100'.
]

{ #category : #test }
ImageFormTest >> testSub [
	"For test subtraction operation. Create two ImagesForm (Magenta and Red). The result should be in an image Blue"
	
	|aImageA aImageB aImageC|
	
	aImageA := self imageFormClass newFrom: (Form extent: 100@100 depth:32).
	aImageB := self imageFormClass newFrom: (Form extent: 100@100 depth:32).
	aImageC := self imageFormClass newFrom: (Form extent: 100@100 depth:32).
	aImageA fillColor: Color magenta.
	aImageB fillColor: Color red.
	aImageC fillColor: Color blue.
	self assert:(aImageA - aImageB) bits equals: aImageC bits.
	self assert: (aImageA colorAt: 0@0) equals: Color magenta.
	self assert: (aImageB colorAt: 0@0) equals: Color red.
]

{ #category : #test }
ImageFormTest >> testSum [
	"For test sum operation. Create two ImagesForm (Red and Blue). The sum should result in an image Magenta"

	| aImageA aImageB aImageC |
	aImageA := self imageFormClass
		newFrom: (self formClass extent: 100 @ 100 depth: 32).
	aImageB := self imageFormClass
		newFrom: (self formClass extent: 100 @ 100 depth: 32).
	aImageC := self imageFormClass
		newFrom: (self formClass extent: 100 @ 100 depth: 32).
	aImageA fillColor: Color red.
	aImageB fillColor: Color blue.
	aImageC fillColor: (Color r: 1.0 g: 0 b: 1.0).
	self assert: (aImageA + aImageB) bits equals: aImageC bits.
	self assert: (aImageA colorAt: 0 @ 0) equals: Color red.
	self assert: (aImageB colorAt: 0 @ 0) equals: Color blue
]
