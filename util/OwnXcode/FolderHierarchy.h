@interface FolderHierarchy : NSObject

/*!
    dirType/
        baseName/
            BackupMovie/
            PlayMovie/
 */
- (instancetype)initWithDirType:(NSSearchPathDirectory)dirType withBaseName:(NSString*)baseName;

@property (nonatomic, readonly) NSURL *rootDirURL;
@property (nonatomic, readonly) NSURL *baseDirURL;
@property (nonatomic, readonly) NSURL *playMovieDirURL;
@property (nonatomic, readonly) NSURL *backupMovieDirURL;

@end
