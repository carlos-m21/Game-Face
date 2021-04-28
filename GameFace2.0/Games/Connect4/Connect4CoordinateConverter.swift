import Foundation
class Connect4CoordinateConverter{
    /*!
     @brief converts from viewcontroller indexPath coordinate to space to model logic coordinate space
     @description uiviewcontroller starts at top left 0,0. model is logicaly 0,0 at bottom right. item in IndexPath becomes the column in model space. and Section becomes row in model space ( but needs to be inverted
     @return a position in format (column:Int, row: Int)
     */
    class func modelPosition(for indexPath: IndexPath) -> BoardPosition {
        return BoardPosition(column:indexPath.item, row: maxCountersPerRow - 1 - indexPath.section)
    }
    class func viewPosition(for modelPosition:BoardPosition)-> IndexPath{
        return IndexPath(item: modelPosition.column, section: maxCountersPerRow - 1 - modelPosition.row)
    }
    
}
