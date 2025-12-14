# MatroskaBridge 计划（libmatroska/libebml 路线）

## 目标
- 为 MKV/MKA/WebM 提供读写标签与封面支持，接口保持与 TagLibBridge 一致（字典字段：title/artist/album/albumArtist/composer/year/genre/trackNumber/trackTotal/discNumber/discTotal/coverImageData）。
- 仅在 TagLib 仓库内实现，不影响现有 TagLib/TagLibBridge；产品侧按扩展名分流调用 MatroskaBridge。

## 依赖选择
- 选用 libmatroska + libebml（轻量，专注容器/元数据）；避免引入完整 FFmpeg。
- 打包方式：优先静态库或 XCFramework 供 SPM 引用，避免运行时依赖。

## 实现步骤
1) 引入依赖  
   - 将 libebml/libmatroska 编译为 macOS 静态库或 XCFramework，添加到 Package.swift（binaryTarget 或 source target）。  
   - 在 MatroskaBridge.mm 中启用 `__has_include` 检测并链接。

2) 读取（MatroskaBridge.readTagsAtPath）  
   - 用 EbmlStream/KaxFile 打开文件。  
   - 遍历 Tags（KaxTags → KaxTag → SimpleTag），获取 VorbisComment 风格的键值：TITLE/ARTIST/ALBUM/ALBUMARTIST/COMPOSER/DATE(或 YEAR)/GENRE/TRACKNUMBER/TRACKTOTAL/DISCNUMBER/DISCTOTAL。  
   - 封面：优先 Attachment 类型 `cover`/`cover.jpg` 等；其次 METADATA_BLOCK_PICTURE（若有）；读取数据写入 coverImageData。

3) 写入（MatroskaBridge.writeTagsAtPath）  
   - 创建/更新 Tags 结构，写入上述字段（SimpleTag）。  
   - 封面：添加/替换 Attachment（MIME `image/jpeg`），或写入 METADATA_BLOCK_PICTURE。  
   - 保留其他标签/轨道信息（仅修改目标字段）。

4) 字段映射细节  
   - YEAR：DATE 或 YEAR；存为字符串。  
   - Track/Disc 总数：TRACKTOTAL/DISCTOTAL；编号：TRACKNUMBER/DISCNUMBER。  
   - 统一使用 UTF-8。

5) 测试  
   - 在 Tests/Fixtures 添加 MKV/MKA/WebM 样本（含/不含封面），更新 fetch-fixtures.sh。  
   - 新增测试：读写回归（字段/封面），无损再读。

6) 发布与兼容  
   - MatroskaBridge 作为独立产品；TagLib/TagLibBridge 不变。  
   - 若依赖不可用，保持当前 “not supported” 行为，不阻塞其他格式。
