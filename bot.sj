const mineflayer = require('mineflayer');

function createBot() {
    const bot = mineflayer.createBot({
        host: 'HeadsSigmas.aternos.me', // <--- REEMPLAZA ESTO POR LA IP DE TU SERVER
        port: 55344,                // Puerto predeterminado de Minecraft
        username: 'bot_C137',    // Nombre gen茅rico del bot/NPC dentro del juego
        version: false              // Autodetecta la versi贸n exacta del servidor (1.8 a 1.21+)
    });

    bot.on('spawn', () => {
        console.log(`[NPC] El bot ha aparecido correctamente en el mapa.`);
        // Si tu servidor No-Premium requiere contrase帽a, descomenta la l铆nea de abajo:
        // setTimeout(() => bot.chat('/login erickJKN'), 4000);
    });

    bot.on('login', () => {
        console.log(`[NPC] Conexi贸n establecida con el servidor de Minecraft.`);
    });

    // Rutina automatizada del NPC: Buscar cofre, interactuar, cerrar y saltar (Cada 45 segundos)
    setInterval(async () => {
        if (!bot || !bot.entity) return;

        try {
            // 1. Localizar el bloque de cofre en un radio de 5 bloques
            const chestBlock = bot.findBlock({
                matching: bot.registry.blocksByName.chest.id,
                maxDistance: 5
            });

            if (chestBlock) {
                console.log('[NPC] Interactuando con el contenedor cercano...');
                
                // 2. Abrir el contenedor (genera la animaci贸n y sonido f铆sico en el servidor)
                const chest = await bot.openChest(chestBlock);
                console.log('[NPC] Contenedor abierto.');
                
                // Mantener la interfaz abierta durante 2 segundos simulando actividad de inventario
                await new Promise(resolve => setTimeout(resolve, 2000));
                
                // 3. Cerrar la interfaz del contenedor
                chest.close();
                console.log('[NPC] Contenedor cerrado.');
            } else {
                console.log('[NPC] Aviso: No se detect贸 ning煤n contenedor v谩lido cerca.');
            }

            // 4. Ejecutar acci贸n de salto f铆sico para evitar la inactividad (Anti-AFK)
            await new Promise(resolve => setTimeout(resolve, 1000));
            bot.setControlState('jump', true);
            setTimeout(() => bot.setControlState('jump', false), 500);
            console.log('[NPC] Acci贸n anti-inactividad completada con 茅xito.');

        } catch (err) {
            console.log(`[NPC] Error en el ciclo de ejecuci贸n: ${err.message}`);
        }
    }, 45000);

    // Sistema de auto-reconexi贸n segura tras expulsiones o reinicios del servidor
    bot.on('end', (reason) => {
        console.log(`[NPC] Conexi贸n finalizada por: ${reason}. Reintentando en 25 segundos...`);
        setTimeout(createBot, 25000);
    });

    bot.on('error', (err) => console.log(`[NPC] Error cr铆tico de red detectado: ${err}`));
}

createBot();
