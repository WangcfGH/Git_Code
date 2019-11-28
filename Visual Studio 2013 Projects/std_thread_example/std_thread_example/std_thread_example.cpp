// std_thread_example.cpp : 定义控制台应用程序的入口点。
//

/*Example1:std::thread 各种构造函数例子如下：
#include "stdafx.h"
#include <iostream>
#include <utility>
#include <thread>
#include <chrono>
#include <functional>
#include <atomic>

void f1(int n)
{
	for (int i = 0; i < 5; ++i) {
		std::cout << "Thread " << n << " executing In f1\n";
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}
}

void f2(int& n)
{
	for (int i = 0; i < 5; ++i) {
		std::cout << "Thread 2 executing In f2\n";
		++n;
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}
}

int _tmain(int argc, _TCHAR* argv[])
{
	int n = 0;
	std::thread t1;						// t1 is not a thread
	std::thread t2(f1, n + 1);			// pass by value
	std::thread t3(f2, std::ref(n));	// pass by reference
	std::thread t4(std::move(t3));		// t4 is now running f2(). t3 is no longer a thread
	t2.join();
	t4.join();
	std::cout << "Final value of n is " << n << '\n';
	std::getchar();
	std::getchar();
	return EXIT_SUCCESS;
}
*/


/*Example2:std::thread 赋值操作 ：
#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>

#include <chrono>    // std::chrono::seconds
#include <iostream>  // std::cout
#include <thread>    // std::thread, std::this_thread::sleep_for

void thread_task(int n) {
	std::this_thread::sleep_for(std::chrono::seconds(n));
	std::cout << "hello thread "
		<< std::this_thread::get_id()
		<< " paused " << n << " seconds" << std::endl;
}

int main(int argc, const char *argv[])
{
	std::thread threads[5];
	std::cout << "Spawning 5 threads...\n";
	for (int i = 0; i < 5; i++) {
		threads[i] = std::thread(thread_task, i + 1);
	}
	std::cout << "Done spawning threads! Now wait for them to join\n";
	for (auto& t : threads) {
		t.join();
	}
	std::cout << "All threads joined.\n";
	std::getchar();
	std::getchar();
	return EXIT_SUCCESS;
}
*/

/* Example3:std::thread 赋值操作 ：
#include "stdafx.h"
#include <iostream>
#include <thread>
#include <chrono>

void foo()
{
	std::this_thread::sleep_for(std::chrono::seconds(3));
}

int main()
{
	std::thread t;
	std::cout << "before starting, joinable: " << t.joinable() << '\n';

	t = std::thread(foo);
	std::cout << "after starting, joinable: " << t.joinable() << '\n';

	t.join();

	std::cout << "after join, joinable: " << t.joinable() << '\n';

	std::getchar();
	std::getchar();
	return EXIT_SUCCESS;
}
*/

/* Example4:std::thread 赋值操作 ：
#include "stdafx.h"
#include <iostream>
#include <chrono>
#include <thread>

void independentThread()
{
	std::cout << "Starting concurrent thread.\n";
	std::this_thread::sleep_for(std::chrono::seconds(5));
	std::cout << "Exiting concurrent thread.\n";
}

void threadCaller()
{
	std::cout << "Starting thread caller.\n";
	std::thread t(independentThread);
	t.detach();
	std::this_thread::sleep_for(std::chrono::seconds(1));
	std::cout << "Exiting thread caller.\n";
	std::cout << "t.jionable is " << t.joinable() << "\n";
}

int main()
{
	threadCaller();
	std::this_thread::sleep_for(std::chrono::seconds(5));

	std::getchar();
	std::getchar();
	return EXIT_SUCCESS;
}
*/