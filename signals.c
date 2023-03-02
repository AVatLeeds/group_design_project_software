#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>

// There is a limit on the allowable dynamic range of signal frequencies based on the amount of memory in the system.
// The memory space of samples should always be normalised to the period of the lowest frequency signal involved in the analysis,
// thereby maximising dynamic range.
// If the quantisation resolution of the signal was 8-bits, this would already take ~4GB for a sample sequence of length 2^32.
// 8-bit maximum sample resolution seems too small. 16-bit seems reasonable. Any more than that and we're seriously going to be running out of memory.
// I think roughly 1E9 (1 GHz) would be an acceptable dynamic range for the sampled signals. If this is the internal representation it can always
// be downsampled to whatever extent is necessary

uint64_t sample_rate;

struct waveform
{

};

#define c   299792458

unsigned int target_range_m = 1;
double tunable_bandwidth_Hz = 5E6;
double tuning_sensitivity_Hz_per_volt = -1E6;
double tuning_frequency_Hz = 1E3;
double v = c / sqrt(permitivity);

uint32_t samples = 8192;

double * generate_timebase_vector(double duration)
{
    int i;
    double * timebase_vector = malloc((samples - 1) * sizeof(double));
    timebase_vector[0] = 0;
    for (i = 1; i < samples; timebase_vector[i] = timebase_vector[i - 1] + (duration / samples), i ++);
    return timebase_vector;
}

double * generate_FMCW_output_signal(double * timebase_vector, double chirp_rate_of_change, double target_range, double substrate_relative_permitivity)
{
    int i;
    double * output_signal = malloc((samples - 1) * sizeof(double));
    double v = c / sqrt(substrate_relative_permitivity);
    double round_trip_time = target_range / v;
    double difference_frequency = round_trip_time * chirp_rate_of_change;
    for (i = 0; i < samples; output_signal[i] = sin(2 * M_PI * difference_frequency * timebase_vector[i]), i ++);
    return output_signal;
}

double * convolve(double * vector_a, double * vector_b, uint32_t num_samples)
{
    int i
    
}

int main()
{

}