#  Igloo Framework

## Description

The framework aims at simplifying management of a shared state of a Swift application.

A bit like Flux could do in the Javascript world but in the Swift world where Dispatch queues are available and everything is not only running on the main thread. So, the framework aims at simplifying state management but also state access.

It comes a lot from 



// TODO: if we want to garantee the order of the operations in the
// pending tasks we should make it a Sequence. An iterate throw it using
// an iterator for exectuing the pending taks. an integer could be used
// interally to express an order over the two queues. The older should
// be executed first in the order created by the generator.
// The method to call here should be:
//
// store.executeExecutablePendingTasks()
//

// The framework which sends task could use just a descriptor of the resources
// manipulated, in which ways in the closure and the closures themeselves. And the frmawork
// would take care of assigning the task to the right queues and handle the pending tasks etc for you.
// I could be possible to specify: the retention policy ,the execution policy (exvery time, after each new request, before each new requests, etc... An importance for the resource could be specified also and used for dispatching to queues of different importances.
// Really important: we should support the try to run when arrive but do not keep it. We should not accumulate too much pending tasks.

