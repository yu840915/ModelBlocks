# ModelBlocks
[![Build Status](https://api.travis-ci.org/yu840915/ModelBlocks.svg)](https://travis-ci.org/yu840915/ModelBlocks)
[![codecov.io](https://codecov.io/github/yu840915/ModelBlocks/badge.svg?branch=master)](https://codecov.io/github/yu840915/ModelBlocks?branch=master)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Object oriented modeling components written in Swift.

## Setup
Add following statement to **Cartfile**

```
github "yu840915/ModelBlocks"
```

And run:

```
carthage update
```


## SimpleAsynchronousOperation
This is an abstract class that implements template methods for asynchronous operation. You can subclass to encapsulate ephemeral tasks like Web API access, interactive UI flows such as picking photo. For more about operation pattern, please see [Advanced NSOperation - WWDC 2015](https://developer.apple.com/videos/play/wwdc2015/226/). To subclass, you need to override `main()` and start your asynchronous job there. After job being done, you need to call `finish()` to tell the operation to take care of subsequent tasks like call completion blocks. 

* Remember, except for cancelled operations, you have to call `finish()` whenever job done, no matter being successful or not. 
* Don't forget to check `isCancelled` at begining of method bodies, it's especially true for those being called from callbacks of asynchronouse APIs.

```Swift
class SimpleAsynchronousOperation {
	//...
	
	override func main() {
		guard !isCancelled else { return }
		//start asynchronous task
	}
	
	func handleTaskCallback() {
		guard !isCancelled else { return }
		//handling logics
		finish()
	}
	
	//...
}
```

To implement cancellation, override `onCancel()`.

## MulticastCallbackNode
`MulticastCallbackNode` is for to N closure style communication pattern. For event source, you create a `MulticastCallbackNode` with closure callback type. The benefit is that you can define your closure with specific argument type, for `Notification`, you lose type information when passing them along `userInfo`.

To invoke callbacks, you call `invokeEach()` to get registered callbacks to invoke.

```Swift
class EventSource {
	//...
	
	let eventACallbacks = MulticastCallbackNode<(EventInfo)->()>()
	
	func notifyEventAHappended(with info: EventInfo) {
		eventACallbacks.invokeEach{$0(info)}
	}
	
	//...
}
```

As the listener, you simply call `add()` on a callback node to register your handling logics. You store the returned registration reference until you want to unregister. To unregister, you simply remove the stored registration reference.

```Swift
class EventListener {
	//...
	
	var eventCallbackRegistration: Any?
	
	func addCallbackToEventSource() {
		eventCallbackRef = eventSource.add {[weak self] info in 
			self?.handleEventSource(info)
		}
	}
	
	func handleEventSource(_ info: EventInfo) {
		//handling logics
	}
	
	func removeCallbackFromEventSource() {
		eventCallbackRef = nil
	}
	
	//...
}
```

## Reference Tracker
`ReferenceTracker` is a simple helper managing external references. It  allows client adds and holds reference with variable. 

```
var reference: Any? = tracker.add("Optional debug info for debug print")
```

When client has done with the reference and nullifies all the holding variables, it automatically removes the reference. 

```
reference = nil
```

It also notifies when references goes from empty to nonempty or vise versa through `isEmptyDidChangeObservers`.

## PaginatedList
`PaginatedList` implements template methods dealing with boilerplate tasks ussually encountered by a simple unidirectional paginated list. It provides basic APIs usually needed for this kind of list like `reload()` and `loadMoreIfAllowed()`. You can use it without subclass, but you have to provide your implementation of `FetchingOperationFactory` and `PaginatedFetchingOperationFactoryType` to tell the list where and how to fetch data.