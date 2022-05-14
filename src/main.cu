#include <iostream>
#include <cstdlib>
#include <cuda.h>
#include <nvml.h>
#include <unistd.h>

int main(int argc, char** argv) {
	if (argc < 4) {
		std::printf("Usage : %s [sleep duration (s)] [valid min clock (MHz)] [valid max clock (MHz)]\n", argv[0]);
		return 1;
	}

	cudaDeviceProp prop;
	cudaGetDeviceProperties(&prop, 0);

	const unsigned sleep_duration = std::stoi(argv[1]);
	const unsigned min_clock = std::stoi(argv[2]);
	const unsigned max_clock = std::stoi(argv[3]);

	nvmlDevice_t device;

	nvmlInit();
	nvmlDeviceGetHandleByIndex(0, &device);

	unsigned freq_in_MHz;
	const auto res = nvmlDeviceGetClock(device, NVML_CLOCK_SM, NVML_CLOCK_ID_CURRENT, &freq_in_MHz);
	if (res != NVML_SUCCESS) {
		std::printf("Error at nvmlDeviceGetClock (error code = %u)\n",
				static_cast<unsigned>(res));
		return 1;
	}
	const auto ill_state = (freq_in_MHz < min_clock) || (freq_in_MHz > max_clock);


	std::printf("[%s] SM Frequency : %u MHz (state=%s)\n",
			prop.name,
			freq_in_MHz,
			ill_state ? "ill" : "good"
			);
	std::fflush(stdout);

	if (ill_state) {
		std::printf("Sleep %u sec\n", sleep_duration);
		std::fflush(stdout);
		sleep(sleep_duration);
	}
}
