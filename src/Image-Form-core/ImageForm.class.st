"
Represent a image in Pharo. 

This lib allows basic manipulate and show images.


Example for open a image:

aImageA := ImageForm open: '/Users/pablo/Documents/Pharo/pwq7S.jpg'.

Example to transform a GrayScale image.

aGrayScaleImageA := aImageA asGrayScale.


Example for sum two images:

aImageB := ImageForm open: '/Users/pablo/Documents/Pharo/pharo.png'.
aResultSum := aImageB - aImageA.

Example to show a image:
aImageA show: 'Image A'.

Example to scaled:

aSacaledImage := aImageA scaledFactor:500 height:100.

Example to flip:

aFlippedImage := aImageA flipHorizontally.

aFlippedImage := aImageA flipVertically.


"
Class {
	#name : #ImageForm,
	#superclass : #Form,
	#category : #'Image-Form-core'
}

{ #category : #'instance creation' }
ImageForm class >> imageTest [
	"comment stating purpose of message"
	| aImage aForm |
	
	aForm := Form extent: 100@100 depth:32.
	aImage := self newFrom: aForm.
	aImage fillColor: Color red.
	
	0 to: 50  do:[:x| 0 to: 50 
				do:[:y| |aPoint|
							aPoint := Point x: x y: y.
							aImage colorAt: aPoint put: Color blue ]].
							
	50 to: 100  do:[:x| 50 to: 100 
				do:[:y| |aPoint|
							aPoint := Point x: x y: y.
							aImage colorAt: aPoint put: Color yellow]].
							
	0 to: 50  do:[:x| 50 to: 100
				do:[:y| |aPoint|
							aPoint := Point x: x y: y.
							aImage colorAt: aPoint put: Color green]].
	^ aImage
]

{ #category : #'instance creation' }
ImageForm class >> newFrom: aForm [
	"comment stating purpose of message"
	| aImage |
	aImage := self new.
	aImage copyFrom: aForm.
	^ aImage
]

{ #category : #'instance creation' }
ImageForm class >> open: aFileName [
	"comment stating purpose of message"
	| aImage aForm |
	aFileName asFileReference exists ifTrue: [ 
		aForm := ImageReadWriter formFromFileNamed: aFileName.
		aImage := self newFrom: aForm.
		^ aImage
	].
	self error: 'File does not exist'.
]

{ #category : #operators }
ImageForm >> + aImage [
	"Sum pixel to pixel two images, and return new ImageForm. The channels that be bigger than 1 is setter in 1. It affects the alpha channel."
	
	|aImageResult|
	
	aImageResult := self deepCopy.
	0 to: self width  do: [:x| 
		0 
			to: self height 
			do: [ :y |  
					| aPoint aColorA aColorB |
					aPoint := Point x: x y: y.
					aColorA := aImageResult colorAt: aPoint.
					aColorB := aImage colorAt: aPoint.
					aImageResult colorAt: aPoint put: aColorA + aColorB ]].
	^ aImageResult

]

{ #category : #operators }
ImageForm >> - aImage [
		"Subtraction pixel to pixel two images, and return new ImageForm. The channels that be lower than 0  is setter in 0.. It affects the alpha channel."
	
	|aImageResult|
	
	aImageResult := self deepCopy.
	0 to: self width  do:[:x| 0 to: self height 
								do:[:y|  
									|aPoint aColorA aColorB aColorC|
									aPoint := (Point x: x y: y).
									aColorA := aImageResult colorAt: aPoint.
									aColorB := aImage colorAt: aPoint.
									aColorC := aColorA - aColorB.
									aImageResult colorAt: aPoint put: aColorC. ]].
	^ aImageResult

]

{ #category : #'image manipulation' }
ImageForm >> applyKernel: aKernel [
	"Apply convolution to image. AKernel is a flattened list. Return a new ImageForm.
	
	anKernel := {{-0.1. -0.1. -0.1}. { -0.1. 0.80. -0.1}. {-0.1. -0.1. -0.1}}.
	anImageResult := anImage applyKernel:  anKernel flattened .
	"
	
	|anImage aDim|
	
	aDim := aKernel size sqrt.
	(aDim = 3 or: aDim = 5 ) ifFalse:[self error: 'only supported 3x3 or 5x5 kernel size'].
	anImage := self deepCopy.
	0  to: self width  do:[:x| 
	0  to: self height do:[:y|  
								|aPoint aColorA|
								aPoint := Point x: x y: y.
								aColorA := self getNeighborhood:
								aPoint kernel: aKernel.
								anImage colorAt: aPoint put: aColorA]].
	
	^anImage.
]

{ #category : #converting }
ImageForm >> asGrayScale [
	"Convert Colors to Gray Colors. Return a new ImageForm. the alpha channel is set in 1."
	
	| aImageForm|
	
	aImageForm := self collectColors:[:each | 
										|aIntensity|
										aIntensity := (0.2125 * each red) + (0.7154 * each green)  + (0.0721 * each blue).
										Color r:aIntensity g: aIntensity b: aIntensity alpha: 1.0. ].
	^ self class newFrom: aImageForm.
	
]

{ #category : #converting }
ImageForm >> asGrayScaleWithAlpha [ 
	"Convert Colors to Gray Colors. Return a new ImageForm. Keep the alpha channel"
	
	| aImageForm|
	
	aImageForm := self collectColors:[:each | 
										|aIntensity|
										aIntensity := (0.2125 * each red) + (0.7154 * each green)  + (0.0721 * each blue).
										Color r:aIntensity g: aIntensity b: aIntensity alpha: each alpha. ].
									
	^ImageForm newFrom: aImageForm.
	
]

{ #category : #'image manipulation' }
ImageForm >> crop: aPoint h: aH w: aW [
	"crop an image begin for aPoint. degrees the image. Return a new ImageForm.
	aCropImage := aImage crop: 0@0 h:200 w: 400. "
	
	| aForm aFormImage|
	
	aForm := Form extent: aW@aH depth:32.
	aFormImage := self deepCopy.
	aPoint x  to: (aPoint x + aW)  do:[:x| aPoint y  to: (aPoint y + aH) 
								do:[:y|  
									|aCoord aNewPoint|
									aCoord := (Point x: x y: y).
									aNewPoint := (aCoord x - aPoint x)@(aCoord y - aPoint y).
									aForm colorAt: aNewPoint put: (aFormImage colorAt: aCoord). ]].
	^ self class newFrom: aForm.
]

{ #category : #'image manipulation' }
ImageForm >> flipHorizontally [
	"Flip Horizontally. Return a new ImageForm."
	
	| aForm aFormImage|
	
	aForm:= super flipBy: #horizontal centerAt: (0@0).
	aFormImage := self class newFrom: aForm.
		
	^ aFormImage
]

{ #category : #'image manipulation' }
ImageForm >> flipVertically [
	"Flip Vertically. Return a new ImageForm."
	
	| aForm aFormImage|
	
	aForm:= super flipBy: #vertical centerAt: (0@0).
	aFormImage := self class newFrom: aForm.
		
	^ aFormImage
]

{ #category : #accessing }
ImageForm >> getNeighborhood: aPoint kernel: aKernel [
 	"Apply convolution to a point. AKernel is a flattened list. Return a new Color.
	
	aPixelColor := aImage getNeighborhood: 0@0 kernel:{0. 0. 0. 0. 1. 0. 0. 0. 0.}.
	
	"
	
	
	|aPoints aRed aGreen aBlue aKernelR aDim|
	aDim := aKernel size sqrt.
	aPoints := self getPointNeighborhood: aPoint ksize: aDim@aDim.
	aRed := 0.
	aGreen := 0.
	aBlue := 0.
	aKernelR := aKernel.
	aPoints collectWithIndex: [:aKPoint :inx| 
											|aKColor aKFactor|
											aKColor := (self colorAt: aKPoint).
											aKFactor := (aKernelR at:inx).
											aRed := aRed + (aKColor red * aKFactor). 
											aGreen := aGreen + (aKColor green * aKFactor).
											aBlue := aBlue + (aKColor blue * aKFactor).		
										].
	^ Color r: aRed g: aGreen  b: aBlue.  
]

{ #category : #accessing }
ImageForm >> getPointNeighborhood: aPoint ksize: aKsize [
 	"Get a Neighbordhood of a point, aKsize is a shape like 3@3. Return a list of points. If the points are out of the image, it repeats the image border.
	
	 aImage getPointNeighborhood: 0@0 ksize: 3@3.
	
	"
	
	|aPoints aXvalues aYvalues factor|
	
	factor := (aKsize x -1 ) / 2.
	aPoints := OrderedCollection new.
	aXvalues := (aPoint x - factor) to: (aPoint x +  factor).
	aYvalues := (aPoint y - factor) to: (aPoint y +  factor).
	
	aXvalues do: [ :x |
		aYvalues do: [ :y |
				|xK yK|
				xK := x.
				yK := y.
				x < 0 ifTrue: [xK := 0]. "this need refactoring"
				y < 0 ifTrue: [yK := 0].
				x > (self width-1) ifTrue: [xK := self width-1].
				y > (self height-1) ifTrue: [yK := self height-1].
				
				aPoints add: xK@yK.
		].
	].
	^aPoints
]

{ #category : #'image manipulation' }
ImageForm >> lighter: aFactor [
	"lighter an image. aFactor is a float from 0 to 1. Return a new ImageForm."
	
	| aForm aFormImage|
	
	aForm:= super lighter:aFactor.
	aFormImage := self class newFrom: aForm.
		
	^ aFormImage
]

{ #category : #'image manipulation' }
ImageForm >> rotateBy: aDeg [
	"rotate aDeg degrees the image. Return a new ImageForm."
	
	| aForm aFormImage |
	aFormImage := self deepCopy.
	aForm:= super rotateBy: aDeg.
	aFormImage := self class newFrom: aForm.
	^ aFormImage
]

{ #category : #'image manipulation' }
ImageForm >> rotateBy: direction centerAt: aPoint [
	"Rotate in a direction with the center in point. Return a new ImageForm. Possible values for
	direction = #left, #right or #pi"
	
	| aForm aFormImage |
	aFormImage := self deepCopy.
	aForm:= super rotateBy: direction centerAt: aPoint.
	aFormImage := self class newFrom: aForm.
		
	^ aFormImage
]

{ #category : #'file in/out' }
ImageForm >> save: aName [
	"save in disk a image. The extension support are .png; .jpg; or .jpge"
	
	('*.png' match: aName) 
		ifTrue: [ self writePNGFileNamed: aName. ^self ].
	
	(('*.jpg' match: aName) | ('*.jpge' match: aName)) 
		ifTrue: [ self writeJPEGfileNamed: aName. ^self ].
		
	self error:'Only support extension: .png; .jpg; or .jpge'.
		
	
]

{ #category : #'image manipulation' }
ImageForm >> scaled: aWidth height: aHeight [
	"Scaled one image. This method try to Keep relation of aspect. Return a new ImageForm."

	^ self class newFrom: (super scaledToSize: (Point x: aWidth y: aHeight))
]

{ #category : #'image manipulation' }
ImageForm >> scaledIntoFormOfSize: aSize [
	"Scaled one image in aSize. Return a new ImageForm width shape aSizeXaSize."

	^ self class newFrom: (super scaledIntoFormOfSize: aSize)
]

{ #category : #accessing }
ImageForm >> shape [
	"return a string with format: widthXheight"

	^ self width printString, 'X', self height printString
]

{ #category : #showing }
ImageForm >> show [
	"show one image in the world"
	
	self show:'Image'
]

{ #category : #showing }
ImageForm >> show: anTitle [
	"show one image in the world with a title. Always sacaled the image in 500x500"
	
	|im|

	im := (ImageMorph withForm: (self scaledIntoFormOfSize:500) ). 
	im withSnapshotBorder.
	im borderWidth: 5.
	im color: (Color gray).
	im openInWindowLabeled: (anTitle, '| ', self shape).
]
