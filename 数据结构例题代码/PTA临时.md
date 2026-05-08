+++
date = '2026-05-08'
draft = false
title = 'PTA临时'
tags = []
categories = ["数据结构"]
+++

> 本文更新于 2026-05-08

# 顺序查找（数组作形参）
```C
int search(int arr[],int n,int x){
    for(int i = 0; i < n; i++){
        if(arr[i] == x) return i;
    }
    return -1;
}
```

**思路：**
1. 设置循环变量 `i`，从 `0` 开始遍历数组。
2. 每遍历一个元素，与目标值 `x` 进行比较。
3. 若相等，直接返回当前下标 `i`。
4. 循环结束仍未找到，返回 `-1` 表示查找失败。
5. 时间复杂度：O(n)。

---

# 顺序查找（顺序表作形参）
```C
int searchSq(SqList L,ElemType x){
    for(int i = 0; i < L.len; i++){
        if(L.data[i] == x) return i;
    }
    return -1;
}
```

**思路：**
1. 顺序查找的核心思路与数组版本完全相同。
2. 区别在于数组边界由 `SqList` 结构体的 `L.len` 控制。
3. 从 `0` 到 `L.len-1` 依次遍历 `L.data[]`。
4. 找到则返回下标，未找到返回 `-1`。

---

# 有序表的插入（数组作形参）
```C
void insert(int a[], int *n, int x) {
    int i = *n - 1;
    while (i >= 0 && a[i] > x) {
        a[i + 1] = a[i];
        i--;
    }
    a[i + 1] = x;
    (*n)++;
}
```

**思路：**
1. 初始化 `i = n - 1`，指向当前数组的最后一个元素。
2. 从后向前寻找插入位置，只要 `a[i] > x`，说明 `x` 应插在这些元素之前。
3. 因此将 `a[i]` 后移一位到 `a[i+1]`，腾出空位。
4. `i` 递减，继续向前比较。
5. 循环结束后，`i+1` 就是 `x` 应该插入的位置。
6. 将 `x` 写入 `a[i+1]`，数组长度 `n` 加一。
7. 由于数组有序，插入后仍然保持有序。

---

# 有序表的插入（顺序表作形参）
```C
void ListInsertByOrder(SqList L, ElemType x){
    int len = L->length;
    if(len == LISTSIZE){
        printf("顺序表已满，无法进行插入操作！");
        return;
    }
    int i = len - 1;
    while(i>=0 && L->elem[i] > x){
        L->elem[i+1] = L->elem[i];
        i--;
    }
    L->elem[i+1] = x;
    L->length++;
    return;
}
```

**思路：**
1. **步骤一**：检查顺序表是否已满，已满则无法插入，直接返回。
2. **步骤二**：获取当前长度 `len`，从 `len-1` 位置开始向前查找插入位置。
3. **步骤三**：将所有大于 `x` 的元素依次后移，腾出插入位置。
4. **步骤四**：循环结束后，在 `i+1` 处写入 `x`。
5. **步骤五**：顺序表长度加一，插入完成。

---

# 有序表的插入（单链表作形参）
```C
LinkList InsertList(LinkList L, EType X){
    LNode* x = (LNode*)malloc(sizeof(LNode));
    x->data = X;
    LNode* pre = (LinkList)malloc(sizeof(LNode));
    pre = L;
    while(pre->next != NULL && pre->next->data > X){
        pre = pre -> next;
    }
    x-> next =  pre->next;
    pre -> next = x;
    return L;
}
```

**思路：**
1. **步骤一**：为新值 `X` 创建一个新节点 `x`。
2. **步骤二**：初始化前驱指针 `pre` 指向链表头 `L`。
3. **步骤三**：向后遍历链表，找到第一个大于 `X` 的节点的前驱 `pre`。
4. **步骤四**：将新节点接入链表：`x->next = pre->next`，`pre->next = x`。
5. 由于链表有序，插入后链表仍然有序。

---

# 合并两个有序数组（数组作形参）
```C
void merge(int* a, int m, int* b, int n, int* c){
    int i = 0,j = 0, k = 0;
    while(i<m && j<n){
        if(a[i] < b[j]){
            c[k++] = a[i++];
        }else if(a[i] > b[j]){
            c[k++] = b[j++];
        }else{
            c[k++] = a[i++];
            c[k++] = b[j++];
        }
    }
    while(i<m)    c[k++] = a[i++];
    while(j<n)    c[k++] = b[j++];
}
```

**思路：**
1. **步骤一**：设置三个指针——`i` 指向数组 `a`，`j` 指向数组 `b`，`k` 指向结果数组 `c`。
2. **步骤二**：双指针同时遍历两数组，每次将较小的元素放入 `c`。
3. **步骤三**：若两元素相等（`==`），则两个都放入 `c`，允许重复值存在。
4. **步骤四**：当其中一个数组遍历完成后，将另一个数组的剩余元素全部复制到 `c`。
5. 此为经典的**二路归并**算法，时间复杂度 O(m+n)。

---

# 合并两个有序表（顺序表作形参）
```C
SqList MergeList_Sq(SqList La, SqList Lb){
    SqList Lc = InitList(MAXSIZE);;
    int i = 0,j = 0,k = 0;
    int iLen = La->length,jLen = Lb->length;
    while(i<iLen && j<jLen){
        if(La->elem[i] <= Lb->elem[j]){
            Lc->elem[k++] = La->elem[i++];
        }else{
            Lc->elem[k++] = Lb->elem[j++];
        }
    }
    while(i<iLen) Lc->elem[k++] = La->elem[i++];
    while(j<jLen) Lc->elem[k++] = Lb->elem[j++];
    Lc -> length = iLen + jLen;
    return Lc;
}
```

**思路：**
1. **步骤一**：初始化一个新的顺序表 `Lc`。
2. **步骤二**：用三个指针 `i、j、k` 分别遍历 `La`、`Lb`、`Lc`。
3. **步骤三**：比较两表中当前元素，较小的复制到 `Lc`。
4. **步骤四**：任一表遍历完后，将另一表的剩余元素全部接入 `Lc`。
5. **步骤五**：设置 `Lc` 的长度为两表长度之和，返回 `Lc`。

---

# 线性表元素的区间删除
```C
List Delete( List L, ElementType minD, ElementType maxD ){
    int j = 0;
    for(int i = 0; i <= L->Last; i++){
        ElementType ele = L->Data[i];
        ElementType jele = L->Data[j];
        if(ele<=minD || ele>=maxD){
            L->Data[j] = ele;
            j++;
        }
    }
    L->Last = j-1;
    return L;
}
```

**思路：**
1. **步骤一**：设置双指针——`i` 用于遍历整个顺序表，`j` 用于标记保留下来的元素应放置的位置。
2. **步骤二**：遍历每个元素 `ele`，判断是否在开区间 `(minD, maxD)` 之内。
3. **步骤三**：若 `ele <= minD` 或 `ele >= maxD`（即不在区间内），则保留。将 `ele` 写入 `L->Data[j]`，`j` 加一。
4. **步骤四**：若在区间内，则跳过（不写入），相当于删除。
5. **步骤五**：遍历结束后，更新 `L->Last = j-1`，即新的最后元素下标。
6. 此为**原地压缩**算法，空间复杂度 O(1)。

---

# 单链表遍历
```C
void Traverse(LinkList L){
    L = L->next;
    while(L != NULL){
        printf("%d ",L->data);
        L = L->next;
    }
}
```

**思路：**
1. **步骤一**：由于链表可能带头结点，先将 `L` 跳过头结点，指向第一个数据节点。
2. **步骤二**：进入循环，只要 `L != NULL` 就继续遍历。
3. **步骤三**：打印当前节点的 `data` 值。
4. **步骤四**：将 `L` 指向下一个节点，继续循环。
5. 循环终止条件为 `L == NULL`（到达链表末尾）。

---

# 链式表的按序号查找
```C
ElementType FindKth( List L, int K ){
    K--;
    int index = 0;
    List p = L;
    while(p != NULL){
        if(index == K){
            return p->Data;
        }
        p = p->Next;
        index++;
    }
    return -1;
}
```

**思路：**
1. **步骤一**：将目标序号 `K` 减一，因为链表下标从 0 开始计数（序号1对应下标0）。
2. **步骤二**：从链表头开始遍历，设置 `index = 0` 记录当前下标。
3. **步骤三**：每经过一个节点，`index++`，当 `index == K` 时返回该节点数据。
4. **步骤四**：若遍历完链表仍未找到，返回 `-1` 表示错误。

---

# 单链表的建立（头插法-逆序建立）
```C
struct ListNode *createlist(){
    struct ListNode* newNode = NULL;
    int data;
    while(scanf("%d",&data) != -1){
        if(data == -1)break;
        struct ListNode* L =
            (struct ListNode*)malloc(sizeof(struct ListNode));
        L->data = data;
        L->next = newNode;
        newNode = L;
    }
    return newNode;
}
```

**思路：**
1. **步骤一**：初始化 `newNode = NULL`，作为当前链表的起始。
2. **步骤二**：循环读入整数，读到 `-1` 时结束输入。
3. **步骤三**：每读入一个数，创建新节点 `L`，将 `L->data` 设为读入的值。
4. **步骤四**：将新节点插入到链表头部——`L->next = newNode`，`newNode = L`。
5. **步骤五**：先读入的数据位于链表尾部，后读入的位于链表头部，最终链表与输入顺序**相反**。

---

# 单链表的建立（尾插法-顺序建立）
```C
LinkList Create (){
    LinkList L = (LinkList)malloc(sizeof(LinkList));
    LinkList head = L;
    head->data = NULL;
    L->next = NULL;

    int data;
    while(scanf("%d",&data) != -1){
        if(data == -1) break;
        LinkList newNode = (LinkList)malloc(sizeof(LinkList));
        newNode->data = data;
        newNode->next = NULL;
        L->next = newNode;
        L = newNode;
    }
    return head;
}
```

**思路：**
1. **步骤一**：创建头结点 `head`（或第一个节点），用指针 `L` 记录当前尾节点。
2. **步骤二**：循环读入整数，读到 `-1` 时结束。
3. **步骤三**：每读入一个数，创建新节点 `newNode`。
4. **步骤四**：将新节点接入链表尾部——`L->next = newNode`，然后 `L = newNode` 更新尾指针。
5. **步骤五**：先读入的数据位于链表头部，最终链表与输入顺序**一致**。

---

# 单链表的按值删除
```C
int DelNode(LinkList head, int deldata){
    int flag = 0;
    LinkList p = head;

    while(p->next != NULL) {
        if(p->next->data == deldata) {
            flag = 1;
            LinkList temp = p->next;
            p->next = temp->next;
            free(temp);
        } else {
            p = p->next;
        }
    }
    return flag;
}
```

**思路：**
1. **步骤一**：设置指针 `p` 指向待比较节点的前驱节点（初始为 `head`）。
2. **步骤二**：遍历链表，判断 `p->next->data` 是否等于目标值 `deldata`。
3. **步骤三**：若相等，说明找到了待删除节点。用临时指针 `temp` 保存该节点，`p->next = temp->next` 绕过它，然后 `free(temp)` 释放内存。`p` 不移动，继续检查。
4. **步骤四**：若不相等，`p` 后移到下一个节点，继续遍历。
5. **步骤五**：找到并删除则 `flag = 1`，返回删除结果。

---

# 单链表的按值查找
```C
LinkList Locate_LinkList(LinkList L, datatype x){
    while(L != NULL && L->data !=x)
        L = L->next;
    return L;
}
```

**思路：**
1. **步骤一**：从链表头部开始逐个节点检查。
2. **步骤二**：每经过一个节点，比较 `L->data` 与目标值 `x`。
3. **步骤三**：若相等，返回该节点指针；若遍历完仍未找到，`L == NULL`，返回 `NULL`。

---

# 单链表的按位置查找
```C
LinkList Findk(LinkList L, int k) {
    if (k <= 0) return NULL;
    int count = 0;
    LinkList p = L;

    while (p != NULL && count != k) {
        p = p->next;
        count++;
    }
    return p;
}
```

**思路：**
1. **步骤一**：先检查 `k <= 0`，非法输入直接返回 `NULL`。
2. **步骤二**：从链表头部开始，设置计数器 `count = 0`。
3. **步骤三**：向后移动指针 `k` 次，每移动一次 `count++`。
4. **步骤四**：若移动过程中到达 `NULL`（节点数不足 `k`），返回 `NULL`。
5. **步骤五**：若成功移动 `k` 步，返回当前节点 `p`。

---

# 带头结点的链式表操作集
```C
List MakeEmpty(){
    struct LNode* head = (struct LNode*)malloc(sizeof(struct LNode));
    head->Data=0;
    head->Next=NULL;
    return head;
}
Position Find(List L, ElementType X ){
    struct LNode* p = L;
    while(p!=NULL){
        if(p->Data == X){
            return p;
        }
        p=p->Next;
    }
    return ERROR;
}
bool Insert( List L, ElementType X, Position P ){
    struct LNode* p = L;
    while(p!=NULL && p->Next != P){
        p=p->Next;
    }
    if(p == NULL) {
        printf("Wrong Position for Insertion\n");
        return false;
    }
    struct LNode* temp = (struct LNode*)malloc(sizeof(struct LNode));
    temp->Data = X;

    temp->Next = p->Next;
    p->Next = temp;
    return true;
}
bool Delete( List L, Position P ){
    struct LNode* p = L;
    while(p!=NULL && p->Next != P){
        p=p->Next;
    }
    if(p==NULL){
        printf("Wrong Position for Deletion\n");
        return false;
    }
    p->Next = P->Next;
    free(P);
    return true;
}
```

**思路：**
1. **MakeEmpty**：创建头结点，初始化数据为0，`Next` 指向 `NULL`，返回链表指针。
2. **Find**：从头结点遍历，依次比较每个节点的 `Data` 是否等于 `X`，找到则返回该节点指针。
3. **Insert**：
   - 步骤一：先遍历找到 `P` 的前驱节点 `p`（条件 `p->Next == P`）。
   - 步骤二：若未找到前驱（`p == NULL`），说明 `P` 不在链表中，报错并返回 `false`。
   - 步骤三：创建新节点 `temp`，将其插入到 `p` 之后——`temp->Next = p->Next`，`p->Next = temp`。
4. **Delete**：
   - 步骤一：同样先找到待删除节点 `P` 的前驱 `p`。
   - 步骤二：若未找到前驱，报错并返回 `false`。
   - 步骤三：`p->Next = P->Next` 绕过 `P`，然后 `free(P)` 释放内存。

---

# 删除单链表偶数节点
```C
struct ListNode *createlist() {
    struct ListNode *head = NULL, *tail = NULL;
    int data;
    while (scanf("%d", &data) != -1 && data != -1) {
        struct ListNode *newNode = (struct ListNode *)malloc(sizeof(struct ListNode));
        newNode->data = data;
        newNode->next = NULL;

        if (head == NULL) {
            head = newNode;
            tail = head;
        } else {
            tail->next = newNode;
            tail = newNode;
        }
    }
    return head;
}

struct ListNode *deleteeven(struct ListNode *head) {
    // 步骤一：处理头部连续的偶数节点
    while (head != NULL && head->data % 2 == 0) {
        struct ListNode *temp = head;
        head = head->next;
        free(temp);
    }

    // 步骤二：若链表已空，直接返回
    if (head == NULL) return NULL;

    // 步骤三：处理后续节点中的偶数
    struct ListNode *p = head;
    while (p->next != NULL) {
        if (p->next->data % 2 == 0) {
            struct ListNode *temp = p->next;
            p->next = temp->next;
            free(temp);
        } else {
            p = p->next;
        }
    }
    return head;
}
```

**思路：**
1. **createlist**：尾插法建立链表，读到 `-1` 结束，过程同前文"单链表的建立（尾插法）"。
2. **deleteeven**：
   - **步骤一**：处理头部连续出现的偶数节点——只要 `head` 为偶数，就头指针后移并释放原头节点。此过程可能连续删除多个偶数。
   - **步骤二**：若链表已删空（`head == NULL`），直接返回 `NULL`。
   - **步骤三**：此时头节点必为奇数。用 `p` 记录待检查节点的前驱，遍历剩余链表。
   - **步骤四**：若 `p->next` 为偶数，则绕过它并释放；若为奇数，则 `p` 后移继续检查。
   - 注意：删除偶数节点后 `p` **不移动**，因为新顶替上来的 `p->next` 还需要检查。

---

# 两个有序链表序列的合并
```C
List Merge(List L1,List L2){
    List dummy = (List)malloc(sizeof(struct Node));
    dummy->Next = NULL;
    List list1 = L1->Next;
    List list2 = L2->Next;
    List curr = dummy;
    while(list1!=NULL && list2!=NULL){
        if(list1->Data >= list2->Data){
            curr->Next  = list2;
            curr = list2;
            list2 = list2->Next;
        }else{
            curr->Next = list1;
            curr = list1;
            list1 = list1->Next;
        }
    }
    curr->Next = (list1 != NULL) ? list1 : list2;
    L1->Next = NULL;
    L2->Next = NULL;
    return dummy;
}
```

**思路：**
1. **步骤一**：创建一个虚拟头结点 `dummy`，用它简化边界处理，`curr` 指向结果链表当前尾节点。
2. **步骤二**：跳过两链表的头结点，分别用 `list1` 和 `list2` 指向第一个数据节点。
3. **步骤三**：同时遍历两链表，每次比较 `list1` 和 `list2` 的数据，较小的节点接入结果链表，并后移对应指针。
4. **步骤四**：当任一链表遍历完成后，将另一链表的剩余部分直接接到结果链表末尾。
5. **步骤五**：断开原链表的连接（`L1->Next = NULL`，`L2->Next = NULL`），返回 `dummy->Next`。

---

# 递增的整数序列链表的插入
```C
List Insert( List L, ElementType X ){
    List p = L;
    while (p->Next != NULL && p->Next->Data < X) {
        p = p->Next;
    }
    List newNode = (List)malloc(sizeof(struct Node));
    newNode->Data = X;
    newNode->Next = p->Next;
    p->Next = newNode;
    return L;
}
```

**思路：**
1. **步骤一**：链表带头结点，用 `p` 从头结点开始向后遍历。
2. **步骤二**：循环条件 `p->Next != NULL && p->Next->Data < X`，即向后移动直到 `p->Next` 是第一个 **大于等于** `X` 的节点的前驱。
3. **步骤三**：找到位置后，创建新节点 `newNode`。
4. **步骤四**：将新节点接入——`newNode->Next = p->Next`，`p->Next = newNode`。
5. 由于链表有序，插入后仍保持递增。

---

# 单链表逆转
```C
List Reverse( List L ){
    if (L == NULL || L->Next == NULL) return L;
    struct Node* pre = NULL;
    struct Node* curr = L;
    struct Node* next = NULL;
    while(curr!=NULL){
        next = curr->Next;
        curr->Next = pre;
        pre = curr;
        curr  = next;
    }
    return pre;
}
```

**思路：**
1. **步骤一**：处理边界情况——空链表或只有单节点，直接返回。
2. **步骤二**：初始化三个指针：`pre = NULL`（最终成为新头），`curr = L`（当前处理节点），`next` 用于暂存 `curr->next`。
3. **步骤三**：进入循环，每次处理一个节点的指向反转：
   - 保存 `next = curr->Next`；
   - 将 `curr->Next` 指向 `pre`（完成反转）；
   - `pre` 后移到 `curr`；
   - `curr` 后移到 `next`。
4. **步骤四**：当 `curr == NULL` 时循环结束，`pre` 指向原链表最后一个节点，即新链表的头结点。

---

# 单链表分段逆转
```C
void K_Reverse( List list, int k ){
   if (k <= 1 || list == NULL || list->length < k)
        return;
    Position pre = list->head;//待转部分的前驱节点
    Position start = pre->next;//待转部分的第一个节点
    int rest = list->length;//剩余节点数量
    while(rest >= k){
        //正常反转链表
        Position prev = NULL;
        Position curr = start;
        Position next = NULL;
        for(int i=0;i<k;i++){
            next = curr->next;
            curr->next = prev;
            prev = curr;
            curr = next;
        }
        //将上一段末尾 接 这一段的头prev
        pre->next = prev;
        //将这一段末尾 接 下一段开头
        start->next = curr;
        //移动pre
        pre = start;
        //移动start
        start = curr;


        rest -=k;
    }

}
```

**思路：**
1. **步骤一**：检查边界——`k <= 1` 或节点数不足 `k` 时直接返回。
2. **步骤二**：`pre` 指向待反转段的前驱节点，`start` 指向待反转段的第一个节点，`rest` 记录剩余节点数。
3. **步骤三**：进入大循环，只要剩余节点数 `>= k`，就处理一段。
   - 用三指针法反转 `k` 个节点，得到新头 `prev`，新尾 `curr`。
   - `pre->next = prev`：将上一段末尾接上反转后的新头。
   - `start->next = curr`：将反转段的新尾接上下一段的原始头。
   - `pre = start`：前驱指针后移到反转段的原末尾（现为下一段的前驱）。
   - `start = curr`：待反转段的起始指针后移。
   - `rest -= k`：剩余节点数减少 `k`。
4. **步骤四**：当剩余节点不足 `k` 时退出，完成所有段的逆转。

---

# 求链表的倒数第m个元素
```C
ElementType Find( List L, int m ){
    if(L == NULL) return ERROR;
    List fast = L;
    List slow = L;
    while(m-- && fast!=NULL) fast = fast->Next;
    if(fast == NULL) return ERROR;
    while(fast!=NULL){
        fast = fast->Next;
        slow = slow->Next;
    }
    return slow->Data;
}
```

**思路：**
1. **步骤一**：检查链表是否为空，空则返回错误。
2. **步骤二**：快慢指针初始化——`fast` 和 `slow` 都指向链表头。
3. **步骤三**：`fast` 先向前移动 `m` 步。若移动过程中到达 `NULL`，说明链表节点数不足 `m`，返回错误。
4. **步骤四**：`fast` 和 `slow` 同时向后移动，直到 `fast` 到达链表末尾。
5. **步骤五**：此时 `slow` 正好指向倒数第 `m` 个节点，返回其数据。

---

# 学生成绩链表处理
```C
struct stud_node *createlist(){
    struct stud_node* head = NULL,*tail = NULL;
    int num,score;
    char name[20];
    while(1){
        scanf("%d",&num);
        if(num == 0) break;
        scanf("%s",name);
        scanf("%d",&score);
        //创建学生节点
        struct stud_node* stu =
        (struct stud_node*)malloc(sizeof(struct stud_node));
        stu->num = num;
        int i;
        for(i=0; name[i]!='\0'; i++)
            stu->name[i] = name[i];
        stu->name[i] = '\0';
        stu->score = score;
        //尾插法
        if (head == NULL) {
            head = stu;
            tail = stu;
        } else {
            tail->next = stu;
            tail = stu;
        }
    }
    return head;
}
struct stud_node *deletelist( struct stud_node *head, int min_score ){
    struct stud_node *p, *temp;
    while (head != NULL && head->score < min_score) {
        temp = head;
        head = head->next;
        free(temp);
    }
    if(head == NULL)return NULL;
    p = head;
    while(p->next!=NULL){
        if(p->next->score < min_score){
            temp = p->next;
            p->next = temp->next;
            free(temp);
        }else{
            p = p->next;
        }
    }
    return head;
}
```

**思路：**

**createlist 部分：**
1. **步骤一**：循环读入学号 `num`，若 `num == 0` 则结束输入。
2. **步骤二**：读入姓名 `name` 和成绩 `score`。
3. **步骤三**：创建新学生节点，填入学号、姓名（逐字符拷贝并加终止符）、成绩。
4. **步骤四**：尾插法接入链表——第一个节点时建立 `head` 和 `tail`，后续节点接在 `tail` 后并更新 `tail`。
5. **步骤五**：返回链表头指针。

**deletelist 部分：**
1. **步骤一**：处理头部连续的不及格节点——只要 `head->score < min_score`，就头指针后移并释放原头节点。
2. **步骤二**：若链表已删空（`head == NULL`），直接返回 `NULL`。
3. **步骤三**：此时头节点必符合要求。用 `p` 从头开始向后遍历。
4. **步骤四**：若 `p->next->score < min_score`，绕过并释放该节点，`p` 不移动（继续检查新顶替上来的节点）。
5. **步骤五**：若 `p->next` 符合要求，`p` 后移继续检查。
6. **步骤六**：返回处理后的链表头。

---

# 7-1 一元多项式的乘法与加法运算
**数组映射法**
```C
#include <stdio.h>

int poly1[1001] = {0}; 
int ans_sum[1001] = {0};
int ans_mul[2001] = {0};

void print_poly(int arr[], int max_expon) {
    int first = 1;
    // 从高指数往低指数找
    for (int i = max_expon; i >= 0; i--) {
        if (arr[i] != 0) {
            if (!first) printf(" ");
            printf("%d %d", arr[i], i);
            first = 0;
        }
    }
    // 如果一个项都没有，输出 0 0
    if (first) printf("0 0");
    printf("\n");
}

int main() {
    int n1, n2, c, e;

    // 读入第一个多项式并存入加法结果
    scanf("%d", &n1);
    int p1_max = 0;
    int a_c[1001], a_e[1001]; // 存一下第一个，方便后面做乘法
    for (int i = 0; i < n1; i++) {
        scanf("%d %d", &c, &e);
        a_c[i] = c; a_e[i] = e;
        ans_sum[e] += c;
    }

    // 读入第二个多项式
    scanf("%d", &n2);
    for (int i = 0; i < n2; i++) {
        scanf("%d %d", &c, &e);
        // 直接做加法合并
        ans_sum[e] += c;
        // 直接做乘法累加
        for (int j = 0; j < n1; j++) {
            ans_mul[e + a_e[j]] += c * a_c[j];
        }
    }

    print_poly(ans_mul, 2000);
    print_poly(ans_sum, 1000);

    return 0;
}
```

**思路（数组映射法）：**
1. **步骤一**：创建三个整型数组——`poly1[]` 存第一个多项式，`ans_sum[]` 存加法结果，`ans_mul[]` 存乘法结果。数组下标对应指数，下标处的值对应系数。
2. **步骤二**：读入第一个多项式的 `n1` 项，将每项系数累加到 `ans_sum[指数]` 和 `poly1[指数]` 中（`poly1` 备份以便后续乘法使用）。
3. **步骤三**：读入第二个多项式的 `n2` 项，做两件事：
   - 加法：直接累加到 `ans_sum[指数]`；
   - 乘法：遍历第一个多项式的每一项，将 `c * a_c[j]` 累加到 `ans_mul[e + a_e[j]]`（指数相加，系数相乘）。
4. **步骤四**：按指数从高到低遍历数组，输出所有系数非零项（`ans_mul` 先输出，`ans_sum` 后输出）。
5. **步骤五**：若没有任何非零项，输出 `0 0`。

---

**正常链表解决**
```C
#include <stdio.h>
#include <stdlib.h>

// 定义多项式节点
struct PolyNode {
    int coef; // 系数
    int expon; // 指数
    struct PolyNode *next;
};
typedef struct PolyNode *Polynomial;

// 辅助函数：将新项接到链表尾部
void Attach(int c, int e, Polynomial *pRear) {
    Polynomial P = (Polynomial)malloc(sizeof(struct PolyNode));
    P->coef = c;
    P->expon = e;
    P->next = NULL;
    (*pRear)->next = P;
    *pRear = P; // 更新尾指针
}

// 读入多项式
Polynomial ReadPoly() {
    int N, c, e;
    scanf("%d", &N);
    Polynomial head = (Polynomial)malloc(sizeof(struct PolyNode));
    head->next = NULL;
    Polynomial rear = head;
    while (N--) {
        scanf("%d %d", &c, &e);
        Attach(c, e, &rear);
    }
    return head;
}

// 两个多项式相加
Polynomial Add(Polynomial P1, Polynomial P2) {
    Polynomial t1 = P1->next;
    Polynomial t2 = P2->next;
    Polynomial head = (Polynomial)malloc(sizeof(struct PolyNode));
    head->next = NULL;
    Polynomial rear = head;

    while (t1 && t2) {
        if (t1->expon > t2->expon) {
            Attach(t1->coef, t1->expon, &rear);
            t1 = t1->next;
        } else if (t1->expon < t2->expon) {
            Attach(t2->coef, t2->expon, &rear);
            t2 = t2->next;
        } else {
            int sum = t1->coef + t2->coef;
            if (sum != 0) Attach(sum, t1->expon, &rear);
            t1 = t1->next;
            t2 = t2->next;
        }
    }
    while (t1) { Attach(t1->coef, t1->expon, &rear); t1 = t1->next; }
    while (t2) { Attach(t2->coef, t2->expon, &rear); t2 = t2->next; }
    return head;
}

// 两个多项式相乘
Polynomial Mult(Polynomial P1, Polynomial P2) {
    Polynomial t1 = P1->next;
    Polynomial t2 = P2->next;
    if (!t1 || !t2) return NULL;

    Polynomial head = (Polynomial)malloc(sizeof(struct PolyNode));
    head->next = NULL;

    // 用 P1 的每一项去乘 P2 的每一项
    while (t1) {
        Polynomial tempHead = (Polynomial)malloc(sizeof(struct PolyNode));
        tempHead->next = NULL;
        Polynomial tempRear = tempHead;
        Polynomial p2 = t2;
        
        while (p2) {
            Attach(t1->coef * p2->coef, t1->expon + p2->expon, &tempRear);
            p2 = p2->next;
        }
        
        // 将乘出来的这一行加到总结果里
        Polynomial oldRes = head;
        head = Add(head, tempHead);
        
        // 释放临时链表空间（此处略，考试时可不写，但在工程中很重要）
        t1 = t1->next;
    }
    return head;
}

// 打印多项式
void PrintPoly(Polynomial P) {
    if (!P || !P->next) {
        printf("0 0\n");
        return;
    }
    Polynomial t = P->next;
    int first = 1;
    while (t) {
        if (!first) printf(" ");
        printf("%d %d", t->coef, t->expon);
        first = 0;
        t = t->next;
    }
    printf("\n");
}

int main() {
    Polynomial P1 = ReadPoly();
    Polynomial P2 = ReadPoly();

    Polynomial PP = Mult(P1, P2);
    PrintPoly(PP);

    Polynomial PS = Add(P1, P2);
    PrintPoly(PS);

    return 0;
}
```

**思路（链表法）：**

**ReadPoly 部分：**
1. **步骤一**：读取项数 `N`，创建带头结点的空链表 `head`，尾指针 `rear` 初始指向 `head`。
2. **步骤二**：循环读取 `N` 次系数 `c` 和指数 `e`，调用 `Attach(c, e, &rear)` 将新节点接到链表尾部。
3. **步骤三**：返回链表头指针 `head`。

**Add 部分：**
1. **步骤一**：用 `t1`、`t2` 分别指向两链表的第一个数据节点（跳过头结点）。
2. **步骤二**：同时遍历两链表，按指数大小分情况处理：
   - 若 `t1->expon > t2->expon`，将 `t1` 接入结果链表，`t1` 后移；
   - 若 `t1->expon < t2->expon`，将 `t2` 接入结果链表，`t2` 后移；
   - 若指数相等，系数相加后若非零则接入，`t1`、`t2` 同时后移。
3. **步骤三**：当任一链表遍历完后，将另一链表的剩余节点全部接入结果链表。
4. **步骤四**：返回结果链表的头指针。

**Mult 部分：**
1. **步骤一**：处理边界情况——任一多项式为空则返回 `NULL`。
2. **步骤二**：用 `t1` 遍历第一个多项式的每一项，对每一项：
   - 步骤二.1：用 `t2` 遍历第二个多项式的每一项，调用 `Attach` 生成 `t1->coef * t2->coef`、`t1->expon + t2->expon` 的节点，构成临时结果链表 `tempHead`。
   - 步骤二.2：将 `tempHead` 与已有的 `head` 通过 `Add` 函数合并，更新 `head`。
3. **步骤三**：`t1` 后移，重复以上过程直到 `P1` 所有项遍历完毕。

**PrintPoly 部分：**
1. **步骤一**：检查链表是否为空或只有头结点，若是则输出 `0 0`。
2. **步骤二**：从第一个数据节点开始遍历，用 `first` 标记控制空格输出格式，逐个打印系数和指数。
3. **步骤三**：遍历完毕换行。