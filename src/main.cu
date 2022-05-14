#include <iostream>
#include <cstdlib>
#include <cuda.h>
#include <unistd.h>

int main(int argc, char** argv) {
	if (argc < 4) {
		std::printf("Usage : %s [sleep duration (s)] [valid min clock (MHz)] [valid max clock (MHz)]\n", argv[0]);
		return 1;
	}

	cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop, 0);

	const auto sleep_duration = std::stoi(argv[1]);
	const auto min_clock = std::stoi(argv[2]);
	const auto max_clock = std::stoi(argv[3]);

	const auto freq_in_MHz = prop.clockRate / 1000;
	const auto ill_state = (freq_in_MHz < min_clock) || (freq_in_MHz > max_clock);


	std::printf("[%s] SM Frequency : %d MHz (state=%s)\n",
			prop.name,
			freq_in_MHz,
			ill_state ? "ill" : "good"
			);
	std::fflush(stdout);

	if (ill_state) {
		std::printf("Sleep %d sec\n", sleep_duration);
		std::fflush(stdout);
		sleep(sleep_duration);
	}
}
