1 请简述 Vue 首次渲染的过程。

 

Vue首次渲染主要做了两大操作：

 

1. 初始化实例成员和静态成员，这是跟平台无关的

 

　　1. 实例成员中：实例相关内容，包括实例方法，事件，生命周期

 

　　2. 静态成员中：添加了全局方法，也就是添加在Vue对象上的方法， 比如 Vue.use, Vue.extend, Vue,mixin， Vue.set等。

 

2. 初始化了组件，模版，指令，这是跟平台有关的

 

　　1. 运行环境：需要处理的指令，组件，模块，

 

　　2. 编译环境：需要处理的指令，组件，模块

 

　　3. 将模版转换成 render函数

 

　　4. $mount 方法中，主要在 Dom渲染之前，触发beforeMount方法，

 

　　3. 然后创建渲染Watcher，挂载beforeupdate生命周期的方法，

 

　　4. 调用mountComponent 方法，通过render 函数转换虚拟Dom, 并将虚拟Dom，再转换成真实Dom，显示到界面， 触发mounted方法。

 

2  Vue响应式原理简述

 

数据响应式是指，当数据发生变化自动更新视图，不需要手动操作dom，

 

第一步、入口，initState（）

vm状态的初始化，整个响应式是从init方法中开始的，在init方法中，调用initState方法初始化状态，在initState方法中调用initData（），将data属性注入到vue实例上，并且调用observe（）将其转化为响应式对象，observe是响应式的入口

 

第二步、observe（value）

位于src/core/observer/index.js，首先判断value是否是对象，如果不是对象直接返回，判断value对象是否有

 

__ob__,如果有证明value已经做过响应化处理，是响应式数据，则直接返回，如果没有，则在第三步创建observer对象，并将其返回。

 

第三步、Observe()

位于src/core/observer/index.js,给value对象定义不可枚举的__ob__属性，记录当前的observer对象，进行数组的响应化处理，设置数组中的方法push、pop、sort等，这些方法会改变原数组，所以当这些方法被调用的时候，会发送通知，找到observe对象中的dep，调用dep.notify()方法，然后调用数组中的每一个成员，对其进行响应化处理，如果成员是对象，也会将转化为响应式对象，如果value是对象的话，会调用walk()，遍历对象中的每一个成员，调用defineReactive()

 

第四步、defineReactive

src/core/observer/index.js,为每一个属性创建dep对象，如果当前属性是对象，递归调用observe().

 

getter:为每一个属性收集依赖，如果当前属性是对象，也为对象的每一个属性收集依赖，最终返回属性值。

 

setter:保存新值，如果新值是对象，则调用observe,派发更新（发送通知），调用dep.notify()

 

第五步、依赖收集

在watcher对象的get方法中调用pushTarget，会把当前的watcher记录Dep.target属性，访问的data成员的时候收集依赖，访问值的时候会调用defineReactive的getter中收集依赖，把属性对应的watcher对象添加到dep的subs数组中，如果属性是对象，则给childOb收集依赖，目的是子对象添加和删除成员时发送通知。

 

第六步、Watcher

当数据发生变化时，会调用dep.notify()，调用watcher对象的update()方法，在update方法中会调用queueWatcher()，方法中会判断watcher是否被处理，如果没有，则将其添加到queue队列中，并调用flushSchedulerQueue()刷新任务队列，在flushSchedulerQueue中，会触发beforeUpdate钩子函数，然后调用watcher.run（），然后清空上一次的依赖，触发actived钩子函数，触发update钩子函数。

 

3、请简述虚拟 DOM 中 Key 的作用和好处。

        以便它能够跟踪每个节点的身份，在进行比较的时候，会基于 key 的变化重新排列元素顺序。从而重用和重新排序现有元素，并且会移除 key 不存在的元素。方便让 vnode 在 diff 的过程中找到对应的节点，然后成功复用。

    设置key的好处：

        可以减少 dom 的操作，减少 diff 和渲染所需要的时间，提升了性能。

 

4、请简述 Vue 中模板编译的过程。

    缓存公共的 mount 函数，并重写浏览器平台的 mount

    判断是否传入了 render 函数，没有的话，是否传入了 template ，没有的话，则获取 el 节点的 outerHTML 作为 template

    调用 baseCompile 函数

    解析器(parse) 将模板字符串的模板编译转换成 AST 抽象语法树

    优化器(optimize) - 对 AST 进行静态节点标记，主要用来做虚拟DOM的渲染优化

    通过 generate 将 AST 抽象语法树转换为 render 函数的 js 字符串

    将 render 函数 通过 createFunction 函数 转换为 一个可以执行的函数

    将 最后的 render 函数 挂载到 option 中

    执行 公共的 mount 函数