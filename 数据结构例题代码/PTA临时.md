+++
date = '2026-05-08'
draft = false
title = 'PTA临时'
tags = []
categories = ["JavaWeb"]
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

# 顺序查找（顺序表作形参）
```C
int searchSq(SqList L,ElemType x){
    for(int i = 0; i < L.len; i++){
        if(L.data[i] == x) return i;
    }
    return -1;
}
```

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


# 链式表的按序号查找
```C
ElementType FindKth( List L, int K ){
    K--;//1
    int index = 0;
    List p = L;
    while(p != NULL){
        if(index == K){
            return p->Data;
        }
        p = p->Next;
        index++;//1
    }
    return -1;
}
```

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

//20->10->NULL
```

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

# 单链表的按值删除
```C
int DelNode(LinkList head, int deldata){
    int flag = 0;
    LinkList p = head;
    
    while(p->next != NULL) {
        if(p->next->data == deldata) {
            flag = 1;
            LinkList temp = p->next;
            p->next = temp->next; // 绕过要删的节点
            free(temp);
        } else {
            p = p->next;
        }
    }
    return flag;
}
```


# 单链表的按值查找
```C
LinkList Locate_LinkList(LinkList L, datatype x){
    while(L != NULL && L->data !=x)
        L = L->next;
    return L;
}
```

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
        p = p->Next;
    }
    //P的前驱节点    P
    //        temp
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
    //P的前驱节点    P
    if(p==NULL){
        printf("Wrong Position for Deletion\n");
        return false;
    }
    p->Next = P->Next;
    free(P);
    return true;
}
```
# 删除单链表偶数节点
```C
struct ListNode *createlist() {
    struct ListNode *head = NULL, *tail = NULL;
    int data;
    // 循环读入，直到读到 -1
    while (scanf("%d", &data) != -1 && data != -1) {
        struct ListNode *newNode = (struct ListNode *)malloc(sizeof(struct ListNode));
        newNode->data = data;
        newNode->next = NULL;

        if (head == NULL) {
            head = newNode; // 第一个节点确立头指针
            tail = head;
        } else {
            tail->next = newNode; // 挂在当前尾部
            tail = newNode;       // 更新尾指针
        }
    }
    return head;
}

struct ListNode *deleteeven(struct ListNode *head) {
    //使用 while 循环处理开头连续的偶数
    while (head != NULL && head->data % 2 == 0) {
        struct ListNode *temp = head;
        head = head->next; 
        free(temp);       
    }

    //如果删光了，直接返回
    if (head == NULL) return NULL;

    // head 必为奇数，检查 p 的下一个
    struct ListNode *p = head;
    while (p->next != NULL) {
        if (p->next->data % 2 == 0) {
            struct ListNode *temp = p->next;
            p->next = temp->next; // 绕过偶数节点
            free(temp);           // 释放内存
            // 此时不移动 p，留在原地检查新顶替上来的 p->next
        } else {
            p = p->next; // 只有下一个是奇数，才向后移动
        }
    }
    return head;
}

```


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
            head = stu; // 第一个节点
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
        head = head->next; // 头指针后移
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