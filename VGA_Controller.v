module VGA_Controller (
  input wire clk,       // Clock input
  input wire reset,     // Reset input
  output reg hsync,     // Horizontal sync signal
  output reg vsync,     // Vertical sync signal
  output reg [2:0] RGB  // 3-bit RGB color
);

  reg [9:0] pixel_x;     // X coordinate counter
  reg [9:0] pixel_y;     // Y coordinate counter
  reg video_on;          // Video enable signal

  // VGA timing generator
  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset pixel counters on reset
      pixel_x <= 0;
      pixel_y <= 0;
    end else begin
      // Update X coordinate
      if (pixel_x < 799) begin
        pixel_x <= pixel_x + 1;
      end else begin
        pixel_x <= 0;
        // Update Y coordinate
        if (pixel_y < 524) begin
          pixel_y <= pixel_y + 1;
        end else begin
          pixel_y <= 0;
        end
      end
    end

    // Generate HSYNC (Horizontal Sync)
    if(pixel_x >= 655 && pixel_x <= 751) begin
      hsync <= 1'b0;
    end else begin
      hsync <= 1'b1;
    end

    // Generate VSYNC (Vertical Sync)
    if (pixel_y >= 512 && pixel_y <= 514) begin
      vsync <= 1'b0;
    end else begin
      vsync <= 1'b1;
    end

    // Generate RGB and Video Enable
    if (pixel_x < 640 && pixel_y < 480) begin
      video_on <= 1'b1;
      RGB <= 3'b100; // Sample color (100 for red)
    end else begin
      video_on <= 1'b0;
      RGB <= 3'b000; // No color (black)
    end
  end
endmodule

module VGA_Controller_TB;
  reg clk;        // Clock signal
  reg reset;      // Reset signal
  wire hsync;     // Horizontal sync signal
  wire vsync;     // Vertical sync signal
  wire [2:0] RGB; // RGB color

  // Instantiate the VGA controller
  VGA_Controller uut (
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .RGB(RGB)
  );

  // Clock generation (25 MHz clock)
  always begin
    #10 clk = ~clk;
  end

  // Initialize signals and run simulation
  initial begin
    clk = 0;
    reset = 0;
    #20 reset = 0; // Apply reset
    #100 reset = 1; // Release reset
    // Monitor the VGA signals
    $monitor("Time=%t, HSYNC=%b, VSYNC=%b, RGB=%b", $time, hsync, vsync, RGB);
    // Simulate for a while
    #2000 $stop;
  end
endmodule
