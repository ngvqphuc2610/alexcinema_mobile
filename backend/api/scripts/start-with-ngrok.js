const { spawn } = require('child_process');
const { updateEnvWithUrl } = require('./update-env');

console.log('🚀 Starting server with ngrok...');

const server = spawn('npm', ['run', 'start:dev'], {
  stdio: 'inherit',
  shell: true,
});

setTimeout(() => {
  console.log('🌐 Starting ngrok tunnel...');

  const ngrok = spawn('ngrok', ['http', '3000', '--log=stdout'], {
    stdio: 'pipe',
    shell: true,
  });

  let lastPublicUrl = null;

  ngrok.stdout.on('data', (data) => {
    const output = data.toString();
    process.stdout.write(output);

    const urlMatch = output.match(
      /https:\/\/[a-zA-Z0-9.-]+\.ngrok[-a-zA-Z0-9]*\.[a-z]+/
    );

    if (urlMatch) {
      const publicUrl = urlMatch[0];

      if (publicUrl !== lastPublicUrl) {
        lastPublicUrl = publicUrl;

        const apiUrl = `${publicUrl}/api`;
        console.log(`\n🔗 Ngrok URL detected: ${apiUrl}`);
        console.log(`📝 Writing ${apiUrl} to Flutter .env...`);

        try {
          updateEnvWithUrl(apiUrl);
        } catch (error) {
          console.error(
            '❌ Failed to update .env with ngrok URL:',
            error.message
          );
        }
      }
    }
  });

  ngrok.stderr.on('data', (data) => {
    process.stderr.write(`Ngrok error: ${data}`);
  });

  ngrok.on('close', (code) => {
    console.log(`ngrok exited with code ${code}`);
  });
}, 3000);
