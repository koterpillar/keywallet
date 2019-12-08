{-# OPTIONS_GHC -Wno-missing-signatures #-}
import Graphics.Implicit

resolution :: Double
resolution = 0.0001

plateWidth = 105

plateHeight = 55

plateThickness = 1.2

plateRounding = 5

holeX = 5

holeY = 12.5

holeRadius = 2

notch1Width = 25

notch1Depth = 15

notch2Width = 25

notch2Depth = 7.5

notchSlantWidth = 5

notchRounding = 2

asymmetryX = 10

asymmetryHeight = 1

asymmetryInterval = 4

asymmetryRounding = 0.5

asymmetryCount = 3

supportX = 40

supportWidth = 2

supportThickness = 4.5

supportInset = 2

supportRounding = 1

flipX :: Double -> Double
flipX x = plateWidth - x

flipY :: Double -> Double
flipY y = plateHeight - y

holes =
  union [hole (fX holeX) (fY holeY) | fX <- [id, flipX], fY <- [id, flipY]]
  where
    hole x y = translate (x, y) $ circle holeRadius

rectRXYWH r (x, y) (w, h) = rectRXYXY r (x1, y1) (x2, y2)
  where
    x1 = x
    x2 = x + w
    y1 = y
    y2 = y + h

rectXYWH = rectRXYWH 0

rectRXYXY r (x1, y1) (x2, y2) = rectR r (xmin, ymin) (xmax, ymax)
  where
    xmin = min x1 x2
    xmax = max x1 x2
    ymin = min y1 y2
    ymax = max y1 y2

rectXYXY = rectRXYXY 0

asymmetry =
  union $ do
    i <- [0 .. asymmetryCount - 1]
    fX <- [id, flipX]
    pure $
      rectRXYXY
        asymmetryRounding
        (fX $ asymmetryX + asymmetryInterval * i, 0)
        ( fX $ asymmetryX + asymmetryInterval * i + asymmetryInterval / 2
        , asymmetryHeight)

notches =
  union [notch notch1Width notch1Depth id, notch notch2Width notch2Depth flipY]
  where
    notch width depth yFn =
      differenceR
        notchRounding
        [ polygonR
            0
            [ (leftX, yFn 0)
            , (leftX2, yFn $ depth * 2)
            , (flipX leftX2, yFn $ depth * 2)
            , (flipX leftX, yFn 0)
            ]
        , rectXYXY (leftX1, yFn depth) (leftX1 + width, yFn $ depth * 2)
        ]
      where
        leftX = (plateWidth - width) / 2 - notchSlantWidth
        leftX1 = leftX + notchSlantWidth
        leftX2 = leftX + notchSlantWidth * 2

plate2 =
  differenceR
    notchRounding
    [ differenceR asymmetryRounding [difference [mainPlate, holes], asymmetry]
    , notches
    ]
  where
    mainPlate = rectR plateRounding (0, 0) (plateWidth, plateHeight)

plate = extrudeR 0 plate2 plateThickness

supports = extrudeR 0 supports2 (plateThickness + supportThickness)
  where
    supports2 =
      union
        [ translate (supportX, supportTop) oneSupport
        , translate
            (plateWidth - supportX - supportWidth, supportTop)
            oneSupport
        ]
    oneSupport = rectR supportRounding (0, 0) (supportWidth, supportHeight)
    supportHeight = plateHeight - notch1Depth - notch2Depth - supportInset * 2
    supportTop = notch1Depth + supportInset

keywallet = union [plate, supports]

main :: IO ()
main = writeBinSTL 0.5 "keywallet.stl" keywallet

