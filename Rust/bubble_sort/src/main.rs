fn main() {
    let mut delay = vec![98, 32, 43, 56, 123, 4, 12, 54, 65];
    bubble_sort_v1(&mut delay);
    println!("bubble_sort_v1冒泡排序结果为{:?}", delay);

    bubble_sort_v2(&mut delay);
    println!("bubble_sort_v2冒泡排序结果为{:?}", delay);
}

fn bubble_sort_v1(vec: &mut Vec<u32>) -> Vec<u32> {
    let mut list = Vec::new();
    let length = vec.len();
    let mut j = 0;

    while j < length - 1 {
        let mut i = 0;
        while i < (length - 1 - j) {
            if vec[i] > vec[i + 1] {
                let temp = vec[i + 1];
                vec[i + 1] = vec[i];
                vec[i] = temp;
            }
            i += 1;
        }
        j += 1;
        list.push(vec[length - j]);
    }
    list
}

fn bubble_sort_v2<T: PartialOrd + Copy>(list: &mut Vec<T>) -> &Vec<T> {
    for _i in 0..list.len() {
        for x in 0..list.len() - 1 {
            // 实际交换次数等于 n-1
            if list[x] > list[x + 1] {
                list.swap(x, x + 1); // 元素交换位置
            }
        }
    }
    list
}
