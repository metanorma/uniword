# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Border style enumeration
    #
    # Represents border line styles from OOXML specification
    class BorderStyleValue < Lutaml::Model::Type::String
      # Full ST_Border enumeration from ECMA-376 (wml.xsd)
      VALUES = %w[nil none single thick double dotted dashed dotDash dotDotDash
                  triple thinThickSmallGap thickThinSmallGap
                  thinThickThinSmallGap thinThickMediumGap thickThinMediumGap
                  thinThickThinMediumGap thinThickLargeGap thickThinLargeGap
                  thinThickThinLargeGap wave doubleWave dashSmallGap
                  dashDotStroked threeDEmboss threeDEngrave outset inset apples
                  archedScallops babyPacifier babyRattle balloons3Colors
                  balloonsHotAir basicBlackDashes basicBlackDots
                  basicBlackSquares basicThinLines basicWhiteDashes
                  basicWhiteDots basicWhiteSquares basicWideInline
                  basicWideMidline basicWideOutline bats birds birdsFlight
                  cabins cakeSlice candyCorn celticKnotwork certificateBanner
                  chainLink champagneBottle checkedBarBlack checkedBarColor
                  checkered christmasTree circlesLines circlesRectangles
                  classicalWave clocks compass confetti confettiGrays
                  confettiOutline confettiStreamers confettiWhite
                  cornerTriangles couponCutoutDashes couponCutoutDots crazyMaze
                  creaturesButterfly creaturesFish creaturesInsects
                  creaturesLadyBug crossStitch cup decoArch decoArchColor
                  decoBlocks diamondsGray doubleD doubleDiamonds earth1 earth2
                  earth3 eclipsingSquares1 eclipsingSquares2 eggsBlack fans
                  film firecrackers flowersBlockPrint flowersDaisies
                  flowersModern1 flowersModern2 flowersPansy flowersRedRose
                  flowersRoses flowersTeacup flowersTiny gems gingerbreadMan
                  gradient handmade1 handmade2 heartBalloon heartGray hearts
                  heebieJeebies holly houseFunky hypnotic iceCreamCones
                  lightBulb lightning1 lightning2 mapPins mapleLeaf
                  mapleMuffins marquee marqueeToothed moons mosaic musicNotes
                  northwest ovals packages palmsBlack palmsColor paperClips
                  papyrus partyFavor partyGlass pencils people peopleWaving
                  peopleHats poinsettias postageStamp pumpkin1 pushPinNote2
                  pushPinNote1 pyramids pyramidsAbove quadrants rings safari
                  sawtooth sawtoothGray scaredCat seattle shadowedSquares
                  sharksTeeth shorebirdTracks skyrocket snowflakeFancy
                  snowflakes sombrero southwest stars starsTop stars3d
                  starsBlack starsShadowed sun swirligig tornPaper
                  tornPaperBlack trees triangleParty triangles triangle1
                  triangle2 triangleCircle1 triangleCircle2 shapes1 shapes2
                  twistedLines1 twistedLines2 vine waveline weavingAngles
                  weavingBraid weavingRibbon weavingStrips whiteFlowers
                  woodwork xIllusions zanyTriangles zigZag zigZagStitch
                  custom].freeze
    end

    # Individual border definition
    #
    # Represents a single border (top, bottom, left, right) with style,
    # size, spacing, and color attributes.
    # style is ST_Border, color is ST_HexColor, themeColor is
    # ST_ThemeColor (ECMA-376).
    #
    # @example Creating a border
    #   border = Border.new(
    #     style: "single",
    #     size: 4,
    #     space: 1,
    #     color: "auto"
    #   )
    class Border < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :style, BorderStyleValue, values: BorderStyleValue::VALUES
      attribute :size, :integer      # Size in eighths of a point (1-96)
      attribute :space, :integer     # Spacing offset in points (0-31)
      attribute :color, Ooxml::Types::HexColorValue
      attribute :theme_color, Ooxml::Types::ThemeColorValue,
                values: Ooxml::Types::ThemeColorValue::VALUES
      attribute :theme_shade, :string

      xml do
        # Use "border" as element name for standalone parsing
        element "border"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :style
        map_attribute "sz", to: :size
        map_attribute "space", to: :space
        map_attribute "color", to: :color
        map_attribute "themeColor", to: :theme_color
        map_attribute "themeShade", to: :theme_shade
      end
    end
  end
end
