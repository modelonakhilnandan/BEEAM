within HPF.Utilities;

function fft_fromMagPhaseOddHrms "Get FFT (complex) from magnitudes and phase (Odd harmonics)"
  extends Modelica.Icons.Function;
  input Real mag[:] "Magnitude data of the harmonics (Odd: h=1,3,5)";
  input Real arg[:] "Phase data of the harmonics (Odd)";
  input Integer N "Size of the FFT";
  output Real yRe[N] "FFT coefficients, real part";
  output Real yIm[N] "FFT coefficients, real part";
  /*
          int func_fft_getCmplxMagArg_OddHrms(double *mag, size_t szMag, double *arg, size_t szArg, int N, double *fftRe, double *fftIm)
         */

  external "C" func_fft_getCmplxMagArg_OddHrms(mag, size(mag, 1), arg, size(arg, 1), N, yRe, yIm) annotation(
    Include = "#include \"fft_utils.c\"",
    IncludeDirectory = "modelica://HPF/Resources/source");
  annotation(
    Documentation(info = "<html><head></head><body>This function computes an FFT from magnitude and phase information (odd harmonics only). Inputs are magnitude, phase and the sampling frequency.&nbsp;<div><br></div><div>Most of the relevant information of a Fourier transform of a time series waveform is present in the the first few harmonics. The rest of the higher harmonics are small in magnitude and hence can be set to zero. Given the sampling frequency, the function reconstructs the fft (complex form) of the given magnitude and phase data.</div><div><br></div><div>User would then use the output complex FFT values to run an IFFT and get a time domain waveform.</div><div><br></div><div>The input data is of the form,</div><div><br></div><div>Harmonic number <span class=\"Apple-tab-span\" style=\"white-space:pre\">	</span>| Input vector index</div><div>1 (fundamental)<span class=\"Apple-tab-span\" style=\"white-space: pre;\">	</span><span class=\"Apple-tab-span\" style=\"white-space: pre;\">	</span>| 1</div><div>3 <span class=\"Apple-tab-span\" style=\"white-space:pre\">			</span>| 2</div><div>5<span class=\"Apple-tab-span\" style=\"white-space:pre\">			</span>| 3</div><div>.</div><div>..</div><div>...</div><div><span class=\"Apple-tab-span\" style=\"white-space:pre\">	</span></div><div>(Modelica implementation of the function from matlab (Avpreet Othee, Colorado State University)</div><div>)</div></body></html>"));
end fft_fromMagPhaseOddHrms;