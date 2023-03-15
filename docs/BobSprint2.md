

# Proud of
Simulation: We're proud of the simulation that we created to test our game because it allows us to identify and address potential issues before the game is released. This helps ensure that the game is as polished and bug-free as possible.

PPU: Our use of an FPGA-based PPU (Picture Processing Unit) in our game engine allows us to achieve high-quality graphics and smooth animation. This is important because it helps create an immersive and engaging gaming experience.

Upscaling: We've implemented a sophisticated upscaling that allows us to scale up our game. This Ensures that our game runs smoothly and without any

Collisions: We've put a lot of effort into making sure that our collision detection system is accurate and reliable. This ensures that the game mechanics work as intended and that players are able to navigate the game world without frustration.

Artwork: We're proud of the artwork that was created which is stunning and imaginative artwork that brings the game world to life. From character designs to background artwork, every aspect of the game has been given careful attention to ensure that it looks as good as it plays. And more is coming!
# Challenges
Upscaling: While our upscaling algorithm is sophisticated, one of the challenges we faced was synchronization. Because we're upscaling in real-time, we had to ensure that the upscaling process didn't cause any lag or delay in the game. This required careful optimization of the algorithm and synchronization with other game components.

PPU: While the use of an FPGA-based PPU allowed us to achieve high-quality graphics, it also presented some challenges. Specifically, the limited resources of the FPGA required us to optimize the PPU code to ensure that it could handle the demands of real-time gameplay.

Communication bug fixes on the STM32: As with any complex system, we encountered some bugs in the communication between the STM32 microcontroller and the other components of the system. This required careful debugging and troubleshooting to identify and fix the issues.

Collisions: For memory and speed reasons it was not possible to have a circle-to-circle collision with every entity/object/tile. So this was split into 2. For the collision with the map a lot of work was needed to have the collision working correctly.  

SPI communication: Configuring the SPI module on the STM32 was fairly easy but programming a SPI receiver on the FPGA turned out to be harder. There is no SPI module that is configurable on the FPGA, so this one is designed by ourself

