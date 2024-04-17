import Foundation


/**
 Struct for defining the categories of physics objects.
 */
struct PhysicsCategory{
    /// Non-physics objects.
    static let none = 0
    
    /// Tank physics objects.
    static let tank = 1 << 0
    
    /// LevelSquare physics objects.
    static let levelSquare = 1 << 1
    
    /// Projectile physics objects.
    static let projectile = 1 << 2
}
