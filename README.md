# ChatSandbox

## Demo
### Show isRead status
![is-read-1](https://github.com/gates1de/ChatSandbox/blob/master/demos/is-read-1.gif)

### Show isSent status
| Normal (Online) | Offline -> Online |
|:---:|:---:|
| ![is-sent-1](https://github.com/gates1de/ChatSandbox/blob/master/demos/is-sent-1.gif) | ![is-sent-2](https://github.com/gates1de/ChatSandbox/blob/master/demos/is-sent-2.gif) |


## Preparation
### Firestore
1. Create project
2. Download `GoogleService-Info.plist` & Add to this project
3. Create `rooms` collection & Add `room1` document & Create `chatMessages` collection (`rooms` sub collection)
```
* rooms

lastMessage: string
lastMessageUserName: string
iconURL: string
userIds: array
userNames: array
createdAt: timestamp
updatedAt: timestamp


* chatMessages

userId: string
userName: string
isSent: boolean
message: string
sentAt: timestamp
typeRawValue: string
isReadUserId: array
```

### iOS
1. Execute `pod install`
2. Create xcconfig file
```
#include "Pods/Target Support Files/Pods-ChatSandbox/Pods-ChatSandbox.debug.xcconfig"

PRODUCT_BUNDLE_IDENTIFIER = com.<your orgnization name>.chatsandbox
PRODUCT_NAME              = ChatSandbox
PRODUCT_MODULE_NAME       = ChatSandbox
```
