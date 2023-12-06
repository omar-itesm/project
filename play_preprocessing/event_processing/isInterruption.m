function is_interruption = isInterruption(event)
    is_interruption = strcmp(event.eventName, 'Interruption');
end